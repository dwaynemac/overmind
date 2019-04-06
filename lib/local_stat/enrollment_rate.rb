class LocalStat
  module EnrollmentRate

    def self.included(base)
      base.extend(ClassMethods)
    end

    def calculate_enrollment_rate(options={})
      e = options[:enrollments] || value_for(:enrollments)
      i = options[:p_interviews] || value_for(:p_interviews)

      if i && e && i > 0
        v = ((e.to_f / i.to_f)*10000).to_i
        (v>10000)? nil : v
      else
        nil
      end
    end
    
    def reduce_enrollment_rate(scope)
      if scope.nil?
        raise "need scope to reduce enrollment_rate"
      end
      cache_key = "reduced_enrollment_rate_#{Digest::SHA256.hexdigest(scope.to_sql)}"
      ret = Rails.cache.read(cache_key)
      if ret.nil?
        p_interviews_sum = scope.where(name: :p_interviews).sum(:value)
        enrollments_sum = scope.where(name: :enrollments).sum(:value)
        ret = calculate_enrollment_rate(enrollments: enrollments_sum, p_interviews: p_interviews_sum)
        unless ret.nil?
          Rails.cache.write(cache_key, ret, expires_in: 5.minutes)
        end
      end
      ret

    end

    module ClassMethods
      def enrollment_rate_dependencies
        [:enrollments, :p_interviews]
      end
    end

  end
end

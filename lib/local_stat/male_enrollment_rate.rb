class LocalStat
  module MaleEnrollmentRate

    def self.included(base)
      base.extend(ClassMethods)
    end

    def calculate_male_enrollment_rate(options={})
      e = options[:male_enrollments] || value_for(:male_enrollments)
      i = options[:male_p_interviews] || value_for(:male_p_interviews)

      if i && e && i > 0
        v = ((e.to_f / i.to_f)*10000).to_i
        (v>10000)? nil : v
      else
        nil
      end
    end

    def reduce_male_enrollment_rate(scope)
      if scope.nil?
        raise "need scope to reduce enrollment_rate"
      end
      cache_key = "reduced_male_enrollment_rate_#{Digest::SHA256.hexdigest(scope.to_sql)}"
      ret = Rails.cache.read(cache_key)
      if ret.nil?
        p_interviews_sum = scope.where(name: :male_p_interviews).sum(:value)
        enrollments_sum = scope.where(name: :male_enrollments).sum(:value)
        ret = calculate_male_enrollment_rate(male_enrollments: enrollments_sum, male_p_interviews: p_interviews_sum)
        unless ret.nil?
          Rails.cache.write(cache_key, ret, expires_in: 5.minutes)
        end
      end
      ret

    end
    
    module ClassMethods
      def male_enrollment_rate_dependencies
        [:male_enrollments, :male_p_interviews]
      end
    end
  end
end

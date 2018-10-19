class LocalStat
  module DropoutRate
    def calculate_dropout_rate(options={})
      d = options[:dropouts] || value_for(:dropouts)
      s = options[:students] || value_for(:students)
      if s && s > 0 && d
        (d.to_f / (s+d).to_f * 10000.0).to_i
      else
        nil
      end
    end
    
    def dropout_rate_dependencies
      [:dropouts, :students]
    end
    
    # options:
    #   :scope # ActiveRecord scope with school, federation, ref_date, etc.
    #   scope should be query of stats to reduce EXCEPT for the names.   
    def reduce_dropout_rate(stats_scope)
      if stats_scope.nil?
        raise 'need stats_scope to reduce dropout_rate'
      end
      cache_key = "reduced_dropout_rate_#{Digest::SHA256.hexdigest(stats_scope.to_sql)}"
      ret = Rails.cache.read(cache_key)
      if ret.nil?
        students_sum = stats_scope.where(name: :students).sum(:value)
        dropouts_sum = stats_scope.where(name: :dropouts).sum(:value)
        ret = calculate_dropout_rate(dropouts: dropouts_sum, students: students_sum)
        unless ret.nil?
          Rails.cache.write(cache_key, ret, expires_in: 5.minutes)
        end
      end
      ret
    end
  end
end

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
    
    # options:
    #   :scope # ActiveRecord scope with school, federation, ref_date, etc.
    #   scope should be query of stats to reduce EXCEPT for the names.   
    def reduce_dropout_rate(stats_scope)
      students_sum = stats_scope.where(name: :students).sum(:value)
      dropouts_sum = stats_scope.where(name: :dropouts).sum(:value)
      calculate_dropout_rate(dropouts: dropouts_sum, students: students_sum)
    end
  end
end

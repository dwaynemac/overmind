class LocalStat
  module MaleStudentsRate

    def self.included(base)
      base.extend(ClassMethods)
    end

    def calculate_male_students_rate
      m = value_for(:male_students)
      s = value_for(:students)

      if m && s && s > 0
        ((m.to_f / s.to_f)*10000).to_i
      else
        nil
      end
    end
    
    module ClassMethods
      def male_students_rate_dependencies
        [:male_students, :students]
      end
    end
  end
end

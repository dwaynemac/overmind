class LocalStat
  module ChelaStudentsRate

    def self.included(base)
      base.extend(ClassMethods)
    end

    def calculate_chela_students_rate
      a = value_for(:chela_students)
      b = value_for(:students)

      if a && b && b > 0
        ((a.to_f / b.to_f)*10000).to_i
      else
        nil
      end
    end
    
    module ClassMethods
      def chela_students_rate_dependencies
        [:chela_students, :students]
      end
    end
  end
end

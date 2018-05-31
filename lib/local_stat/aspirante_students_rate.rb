class LocalStat
  module AspiranteStudentsRate
    def calculate_aspirante_students_rate
      a = value_for(:aspirante_students)
      b = value_for(:students)

      if a && b && b > 0
        ((a.to_f / b.to_f)*10000).to_i
      else
        nil
      end
    end
    
    def aspirante_students_rate_dependencies
      [:aspirante_students, :students]
    end
  end
end

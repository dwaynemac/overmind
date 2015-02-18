class LocalStat
  module ChelaStudentsRate
    def calculate_chela_students_rate
      a = value_for(:chela_students)
      b = value_for(:students)

      if a && b && b > 0
        ((a.to_f / b.to_f)*10000).to_i
      else
        nil
      end
    end
  end
end

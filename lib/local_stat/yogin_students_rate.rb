class LocalStat
  module YoginStudentsRate
    def calculate_yogin_students_rate
      a = value_for(:yogin_students)
      b = value_for(:students)

      if a && b && b > 0
        ((a.to_f / b.to_f)*100).to_i
      else
        nil
      end
    end
  end
end

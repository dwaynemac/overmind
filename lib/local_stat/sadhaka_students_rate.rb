class LocalStat
  module SadhakaStudentsRate
    def calculate_sadhaka_students_rate
      a = value_for(:sadhaka_students)
      b = value_for(:students)

      if a && b && b > 0
        ((a.to_f / b.to_f)*100).to_i
      else
        nil
      end
    end
  end
end

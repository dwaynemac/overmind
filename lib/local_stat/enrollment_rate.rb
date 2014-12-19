class LocalStat
  module EnrollmentRate

    def calculate_enrollment_rate
      e = value_for(:enrollments)
      i = value_for(:p_interviews)

      if i && e && i > 0
        ((e.to_f / i.to_f)*100).to_i
      else
        nil
      end

    end
  end
end

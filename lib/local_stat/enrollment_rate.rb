class LocalStat
  module EnrollmentRate

    def calculate_enrollment_rate
      e = value_for(:enrollments)
      i = value_for(:p_interviews)

      if i && e && i > 0
        v = ((e.to_f / i.to_f)*10000).to_i
        (v>10000)? nil : v
      else
        nil
      end
    end
  end
end

class LocalStat
  module MaleEnrollmentRate

    def calculate_male_enrollment_rate
      e = value_for(:male_enrollments)
      i = value_for(:male_p_interviews)

      if i && e && i > 0
        v = ((e.to_f / i.to_f)*10000).to_i
        (v>10000)? nil : v
      else
        nil
      end
    end
  end
end

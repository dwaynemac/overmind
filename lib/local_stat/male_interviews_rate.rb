class LocalStat
  module MaleInterviewsRate
    def calculate_male_interviews_rate
      m = value_for(:male_interviews)
      s = value_for(:interviews)

      if m && s && s > 0
        ((m.to_f / s.to_f)*10000).to_i
      else
        nil
      end
    end
  end
end

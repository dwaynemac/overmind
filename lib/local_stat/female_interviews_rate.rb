class LocalStat
  module FemaleInterviewsRate
    def calculate_female_interviews_rate
      m = value_for(:female_interviews)
      s = value_for(:interviews)

      if m && s && s > 0
        ((m.to_f / s.to_f)*10000).to_i
      else
        nil
      end
    end
  end
  
  def female_interviews_rate_dependencies
    [:female_interviews,:interviews]
  end
end

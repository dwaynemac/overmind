class LocalStat
  module FemaleDemandRate
    def calculate_female_demand_rate
      m = value_for(:female_demand)
      s = value_for(:demand)

      if m && s && s > 0
        ((m.to_f / s.to_f)*10000).to_i
      else
        nil
      end
    end
    
    def female_demand_rate_dependencies
      [:female_demand, :demand]
    end
  end
end

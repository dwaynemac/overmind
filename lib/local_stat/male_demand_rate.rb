class LocalStat
  module MaleDemandRate
    def calculate_male_demand_rate
      m = value_for(:male_demand)
      s = value_for(:demand)

      if m && s && s > 0
        ((m.to_f / s.to_f)*10000).to_i
      else
        nil
      end
    end
  end
  
  def male_demand_rate_dependencies
    [:male_demand, :demand]
  end
    
end

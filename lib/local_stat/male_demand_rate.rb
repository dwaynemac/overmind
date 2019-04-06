class LocalStat
  module MaleDemandRate

    def self.included(base)
      base.extend(ClassMethods)
    end

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
  
  module ClassMethods
    def male_demand_rate_dependencies
      [:male_demand, :demand]
    end
  end
    
end

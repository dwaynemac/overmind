class LocalStat
  module BegginersDropoutRate

    def calculate_begginers_dropout_rate
      d = value_for(:dropouts_begginers)
      s = value_for(:aspirante_students)
      if d.nil? || s.nil? || s == 0
        nil
      else
        d*10000.0 / (s+d)
      end
    end
    
    def begginers_dropout_rate_dependencies
      [:dropouts_begginers, :aspirante_students]
    end

  end
end
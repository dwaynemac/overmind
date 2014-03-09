class LocalStat
  module BegginersDropoutRate

    def self.included(base)
      base.send(:register_stat, :begginers_dropout_rate)
    end

    def calculate_begginers_dropout_rate
      d = value_for(:dropouts_begginers)
      s = value_for(:aspirante_students)
      if d && s
        s.value*100 / d.value
      end
    end
  end
end

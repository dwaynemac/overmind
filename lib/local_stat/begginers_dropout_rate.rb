class LocalStat
  module BegginersDropoutRate

    def calculate_begginers_dropout_rate
      d = value_for(:dropouts_begginers)
      s = value_for(:aspirante_students, (@ref_date-1.month).end_of_month)
      if d && s
        d*100 / s
      end
    end

  end
end

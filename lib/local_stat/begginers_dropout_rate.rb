class LocalStat
  module BegginersDropoutRate

    def calculate_begginers_dropout_rate
      d = value_for(:dropouts_begginers)
      s = value_for(:aspirante_students, (@ref_date-1.month).end_of_month)
      if d.nil? || s.nil? || s == 0
        nil
      else
        d*10000.0 / s
      end
    end

  end
end

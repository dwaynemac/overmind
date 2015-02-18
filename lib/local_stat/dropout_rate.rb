class LocalStat
  module DropoutRate
    def calculate_dropout_rate
      d = value_for(:dropouts)
      s = value_for(:students, (@ref_date-1.month).end_of_month) 
      if s && s > 0 && d
        (d.to_f / s.to_f * 10000.0).to_i
      else
        nil
      end

    end
  end
end

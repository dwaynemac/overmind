class LocalStat
  module SwasthyaDropoutRate

    def calculate_swasthya_dropout_rate
      d = value_for(:dropouts_intermediates)

      s = [:sadhaka_students,:yogin_students,:chela_students,:graduado_students,
       :assistant_students,:professor_students,:master_students].sum do |stat|
          value_for(stat, (@ref_date-1.month).end_of_month)||0
      end
      if d && s && s!=0
        d*100 / s
      end
    end

  end
end

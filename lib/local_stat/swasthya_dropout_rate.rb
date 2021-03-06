class LocalStat
  module SwasthyaDropoutRate

    def self.included(base)
      base.extend(ClassMethods)
    end

    def calculate_swasthya_dropout_rate
      d = value_for(:dropouts_intermediates)

      s = [:sadhaka_students,:yogin_students,:chela_students,:graduado_students,
       :assistant_students,:professor_students,:master_students].sum do |stat|
          value_for(stat, (@ref_date-1.month).end_of_month)||0
      end
      if d && s && s!=0
        d*10000.0 / s
      end
    end
    
    module ClassMethods
      def swasthya_dropout_rate_dependencies
        [:dropouts_intermediates, :sadhaka_students,:yogin_students,:chela_students,
        :graduado_students, :assistant_students,:professor_students,:master_students]
      end
    end
  end
end

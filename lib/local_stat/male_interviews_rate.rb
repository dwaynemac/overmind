class LocalStat
  module MaleInterviewsRate

    def self.included(base)
      base.extend(ClassMethods)
    end

    def calculate_male_interviews_rate
      m = value_for(:male_interviews)
      s = value_for(:interviews)

      if m && s && s > 0
        ((m.to_f / s.to_f)*10000).to_i
      else
        nil
      end
    end
    
    module ClassMethods
      def male_interviews_rate_dependencies
        [:male_interviews, :interviews]
      end
    end
  end
end

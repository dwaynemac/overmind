require 'spec_helper'

describe LocalStat do

  describe "register_stat" do
    it "allows to register new stats from modules" do
      class LocalStat
        module TestStat

          def self.included(base)
            base.send(:register_stat, :test_stat)
          end

          def calculate_test_stat
          end
        end
      end
      LocalStat.send(:include, LocalStat::TestStat)

      LocalStat.registered_stats.should == [:begginers_dropout_rate, :test_stat]
    end
  end

end

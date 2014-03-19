require 'spec_helper'

describe ReducedStat do

  before do
   10.times{ create(:school_monthly_stat, school: create(:school), value: 2) }
  end

  let(:stats){ SchoolMonthlyStat.all }

  it "uses stats to get ref_date" do
    rs = ReducedStat.new(stats: stats, reduce_as: :sum)
    rs.ref_date.should == Date.today.end_of_month
  end
  it "uses stats to get stat name" do
    rs = ReducedStat.new(stats: stats, reduce_as: :sum)
    rs.name.should == 'enrollments_count'
  end

  describe "initialized with :reduce_as =>" do
    describe "sum" do
      it "adds all values" do
        rs = ReducedStat.new(stats: stats, reduce_as: :sum)
        rs.value.should == 20
      end
    end

    describe "avg" do
      it "calculates average of values" do
        rs = ReducedStat.new(stats: stats, reduce_as: :avg)
        rs.value.should == 2
      end
    end

    describe "nil" do
      it "defaults to sum" do
        rs = ReducedStat.new(stats: stats)
        rs.value.should == 20
      end
    end

  end

end

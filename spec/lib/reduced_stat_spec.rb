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

  describe "#school_id" do
    let(:rs){ReducedStat.new(school: school)}
    context "if school available" do
      let(:school){create(:school)}
      it "returns school.id" do
        expect(rs.school_id).to eq school.id
      end
    end
    context "if school is nil" do
      let(:school){nil}
      it "returns nil" do
        expect(rs.school_id).to be_nil
      end
    end
  end

  describe "#size" do
    let(:rs){ReducedStat.new(stats: [build(:monthly_stat),
                                     build(:monthly_stat),
                                     build(:monthly_stat)])}
    it "amount of stats used in this reduced stat" do
      expect(rs.size).to eq 3
    end
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

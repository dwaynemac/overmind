require 'rails_helper'

describe ReducedStat do

  before do
   10.times{ create(:school_monthly_stat, school: create(:school), value: 2) }
   sms = build(:school_monthly_stat, school: create(:school), value: nil) 
   sms.save(validate: false)
  end

  describe "with stats" do
    let(:stats){ SchoolMonthlyStat.all }
    it "stats is an array" do
      rs = ReducedStat.new(stats: stats)
      expect(rs.stats).to be_a(Array)
    end
    it "uses stats to get ref_date" do
      rs = ReducedStat.new(stats: stats, reduce_as: :sum)
      rs.ref_date.should == Date.today.end_of_month
    end
    it "uses stats to get stat name" do
      rs = ReducedStat.new(stats: stats, reduce_as: :sum)
      rs.name.should == 'enrollments_count'
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
  
  describe "with stats_scope" do
    let(:stats_scope){ SchoolMonthlyStat.scoped }
    it "doesnt call DB on initialization" do
      rs = ReducedStat.new(stats_scope: stats_scope)
      expect(rs.stats_scope).to be_a(ActiveRecord::Relation)
    end
    it "uses stats_scope to get ref_date" do
      rs = ReducedStat.new(stats_scope: stats_scope, reduce_as: :sum)
      rs.ref_date.should == Date.today.end_of_month
    end
    it "uses stats to get stat name" do
      rs = ReducedStat.new(stats_scope: stats_scope, reduce_as: :sum)
      rs.name.should == 'enrollments_count'
    end

    describe "initialized with :reduce_as =>" do
      describe "sum" do
        it "adds all values" do
          rs = ReducedStat.new(stats_scope: stats_scope, reduce_as: :sum)
          rs.value.should == 20
        end
      end

      describe "avg" do
        it "calculates average of values" do
          rs = ReducedStat.new(stats_scope: stats_scope, reduce_as: :avg)
          rs.value.should == 2
        end
      end

      describe "nil" do
        it "defaults to sum" do
          rs = ReducedStat.new(stats_scope: stats_scope)
          rs.value.should == 20
        end
      end

    end
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


end

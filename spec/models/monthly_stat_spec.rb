require 'spec_helper'

describe MonthlyStat do
  before do
    create(:monthly_stat)
  end
  it "should ensure ref_date is end of month date" do
    ms = create(:monthly_stat, ref_date: Date.civil(2012,7,1))
    ms.save
    ms.ref_date.should == Date.civil(2012,7,31)
  end
  it "should allow only one value per name per school per month" do
    should validate_uniqueness_of(:name).scoped_to([:ref_date,:school_id])
  end
  it "should belong to a school" do
    should belong_to :school
  end
  it "should always have a value" do
    should validate_presence_of :value
  end
  it "should always have a ref_date" do
    should validate_presence_of :ref_date
  end
  it "should always have a school" do
    should validate_presence_of :school
  end
  it { should ensure_inclusion_of(:name).in_array(MonthlyStat::VALID_NAMES)}
  
  describe "to_matrix" do
    before do
      s = create(:school)

      @out_of_scope = create(:monthly_stat, school: create(:school), ref_date: Date.civil(2012,1,3), value: 3, name: 'enrollments')

      @apr = create(:monthly_stat, school: s, ref_date: Date.civil(2012,4,1), value: 1, name: 'enrollments')
      @dec = create(:monthly_stat, school: s, ref_date: Date.civil(2012,12,5),value: 6, name: 'enrollments')
      @jan = create(:monthly_stat, school: s, ref_date: Date.civil(2012,1,1), value: 4, name: 'enrollments')
      
      @matrix = s.monthly_stats.to_matrix
    end
    it "should default matrix[stat-name] to {}" do
      @matrix.default.should == {}
    end
    it "should default matrix[stat-name][month] to nil" do
      @matrix[:'no-key'].default.should be_nil
      @matrix[:enrollments].default.should be_nil
    end
    it "should store found stats on matrix keeping scope" do
      @matrix.should == {:enrollments => {1 => @jan, 4 => @apr, 12 => @dec}}
    end
    context "when there is more than one stat in a month (eg: scoping by fed)" do
      before do
        @matrix = MonthlyStat.to_matrix
      end
      it "should set a ReducedStat" do
        @matrix[:enrollments][1].should be_a(ReducedStat)
      end
      it "should store SUM in #value" do
        @matrix[:enrollments][1].value.should == 7
      end
    end
  end

  it "stores service name" do
    should have_db_column :service
  end

  describe ".create_from_service!" do
    let(:school){ create(:school)}
    before do
      School.any_instance.stub(:fetch_stat).and_return('2')
    end
    it "should create a monthly stat On school" do
      expect{MonthlyStat.create_from_service!(school,:enrollments,Date.today)}.to change{school.monthly_stats.count}.by(1)
    end
  end

  describe "#update_from_service" do
    let(:ms){ create(:monthly_stat, value: 1)}
    before do
      School.any_instance.stub(:fetch_stat).and_return('4')
    end
    it "should update value" do
      ms.update_from_service!
      ms.reload.value.should == 4
    end
  end
end
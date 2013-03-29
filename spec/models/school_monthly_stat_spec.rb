require 'spec_helper'

describe SchoolMonthlyStat do

  before do
    if SchoolMonthlyStat.count == 0
      create(:school_monthly_stat)
    end
  end

  it "checks that teacher_id is nil" do
    smt = build(:school_monthly_stat, teacher_id: 123)
    smt.should_not be_valid
    smt.errors[:teacher_id].should_not be_blank
  end

  it "should allow only one value per name per school per month" do
    should validate_uniqueness_of(:name).scoped_to([:ref_date,:school_id])
  end

end

require 'spec_helper'

describe SchoolMonthlyStat do
  it "checks that teacher_id is nil" do
    smt = build(:school_monthly_stat, teacher_id: 123)
    smt.should_not be_valid
    smt.errors[:teacher_id].should_not be_blank
  end
end

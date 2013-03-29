require 'spec_helper'

describe TeacherMonthlyStat do

  before do
    if TeacherMonthlyStat.count == 0
      create(:teacher_monthly_stat)
    end
  end

  it { should belong_to :teacher }

  it "should allow only one value per name per school per month" do
    should validate_uniqueness_of(:name).scoped_to([:ref_date,:school_id,:teacher_id])
  end

end

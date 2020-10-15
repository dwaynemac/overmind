require 'rails_helper'

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

  describe ".sync_from_service" do
    before do
      # mock interaction with services.
      TeacherMonthlyStat.stub(:get_remote_values).and_return([
           {value: 1, full_name: 'Pablo Lewin', padma_username: nil},
           {value: 23, full_name: 'Alex Falke', padma_username: nil},
           {value: 38, full_name: 'Lucia Gagliardini', padma_username: nil}
       ])
    end
    it "creates new TeacherMontlyStat for each teacher" do
      expect{TeacherMonthlyStat.sync_school_from_service(create(:school),:students,Date.civil(2012,6,30))}.to change{TeacherMonthlyStat.count}.by(3)
    end
  end
end

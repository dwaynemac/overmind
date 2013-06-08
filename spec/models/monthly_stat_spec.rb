require 'spec_helper'

describe MonthlyStat do
  before do
    create(:monthly_stat)
  end

  it_behaves_like "a stats matrix"

  context "if teacher_id is not set" do
    it "defaults type to SchoolMonthlyStat" do
      ms = build(:monthly_stat, teacher_id: nil)
      ms.save

      ms.reload.type.should == 'SchoolMonthlyStat'
      SchoolMonthlyStat.last.id.should == ms.id
    end
  end

  it "should ensure ref_date is end of month date" do
    ms = create(:monthly_stat, ref_date: Date.civil(2012,7,1))
    ms.save
    ms.ref_date.should == Date.civil(2012,7,31)
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

  it "stores service name" do
    should have_db_column :service
  end
end
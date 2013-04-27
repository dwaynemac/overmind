require 'spec_helper'

describe Teacher do

  before do
    if Teacher.count == 0
      create(:teacher)
    end
  end

  it { should have_and_belong_to_many :schools }
  it { should have_many :monthly_stats }
  it { should validate_uniqueness_of :username }

  describe ".smart_find" do
    let(:school){create(:school)}
    context "when matching by username" do
      before do
        @teacher = create(:teacher, username: 'dwayne.macgowan', full_name: '')
      end
      it "should update full name" do
        smart_result = Teacher.smart_find('dwayne.macgowan', 'Dwayne Macgowan',school)
        smart_result.should == @teacher
        smart_result.full_name.should == 'Dwayne Macgowan'
      end
    end
    context "when matching by full name" do
      before do
        @teacher = create(:teacher, username: nil, full_name: 'Pepe Lepu')
      end
      it "should update username" do
        sm = Teacher.smart_find('pepe.lepu', 'Pepe Lepu',school)
        sm.should == @teacher
        sm.username.should == 'pepe.lepu'
      end
    end
  end
end

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

  describe "when destroyed" do
    let!(:teacher){create(:teacher)}
    let!(:school){create(:school)}
    before do
      (1..12).each do |i|
        TeacherMonthlyStat.create!(school_id: school.id,
                                 teacher_id: teacher.id,
                                 name: 'enrollment_rate',
                                 value: 1,
                                 ref_date: Date.civil(2010,i,1))
      end
    end
    it "destroys all stats too" do
      teacher.destroy

      expect(TeacherMonthlyStat.count).to eq 0
    end
  end

  describe ".smart_find" do
    let(:school){create(:school)}
    context "when matching by username" do
      before do
        @teacher = create(:teacher, username: 'dwayne.macgowan', full_name: '')
      end
      it "should update full name" do
        smart_result = Teacher.smart_find('dwayne.macgowan', 'Dwayne Macgowan',school)
        expect(smart_result).to be == @teacher
        expect(smart_result.full_name).to be == 'Dwayne Macgowan'
      end
    end
    context "when matching by full name" do
      before do
        @teacher = create(:teacher, username: nil, full_name: 'Pepe Lepu')
      end
      it "should update username" do
        sm = Teacher.smart_find('pepe.lepu', 'Pepe Lepu',school)
        expect(sm).to be == @teacher
        expect(sm.username).to be == 'pepe.lepu'
      end
    end
  end
end

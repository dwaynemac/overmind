require 'spec_helper'

describe School do
  let(:school){create(:school)}
  before do
    school
  end
  it { should belong_to :federation }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
  it { should have_many :monthly_stats }

  it_behaves_like 'it uses NucleoApi for schools' do
    let(:object){School.last || create(:school)}
    let(:klass){School}
  end

  describe "#cache_last_student_count" do
    it "caches nr of students of last month" do
      stat = create(:school_monthly_stat, school: school, ref_date: 1.month.ago, name: 'students')
      create(:school_monthly_stat, school: school, ref_date: 3.months.ago, name: 'students')
      school.cache_last_teachers_count
      school.reload.last_students_count.should == stat.value
    end
  end

  # PadmaAccounts
  it { should have_db_column :account_name }
  it { should allow_value(nil).for(:account_name)}
  it "should validate uniqueness of account_name" do
    create(:school, account_name: 'blah')
    s = FactoryGirl.build(:school, account_name: 'blah')
    s.save
    s.errors.keys.should include :account_name
  end

  describe "#sync_year_stats" do
    let(:school){create(:school)}
    before do
      School.any_instance.stub(:padma2_enabled?).and_return true
      SchoolMonthlyStat.any_instance.stub(:get_remote_value).and_return('1')
      TeacherMonthlyStat.stub(:get_remote_values).and_return([
          {full_name: 'Name', padma_username: 'username', value: '3'},
          {full_name: 'Name2', padma_username: 'username5', value: '3'}
                                                             ])
    end
    it "should create stats for each month for each stat name" do
      n = MonthlyStat::VALID_NAMES.size * 12
      n = n + TeacherMonthlyStat::STATS_BY_TEACHER.size * 2 * 12
      expect{school.sync_year_stats(2011)}.to change{school.monthly_stats.count}.by(n)
    end
    it "should update school#synced_at timestamp" do
      school.sync_year_stats(2011)
      school.synced_at.should be_within(1.minute).of(Time.now)
    end
  end

  describe "#relative_students_count?" do
    subject{ school.relative_students_count? }
    context "if school has relative value and date" do
      let(:school){create(:school,
                          count_students_relative_to_value: 1,
                          count_students_relative_to_date: Date.today
                         )}
      it { should be_true }
    end
    context "if schools does NOT have relative value or date" do
      let(:school){create(:school)}
      it { should be_false }
    end
  end
end

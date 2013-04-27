require 'spec_helper'

describe School do
  before do
    create(:school)
  end
  it { should belong_to :federation }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
  it { should have_many :monthly_stats }

  it_behaves_like 'it uses NucleoApi for schools' do
    let(:object){School.last || create(:school)}
    let(:klass){School}
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

  describe "#padma2_enabled?" do
    context "when migrated_kshema_to_padma_at is nil" do
      subject{School.new }
      its(:padma2_enabled?) { should be_false}
    end
    context "when migrated_kshema_to_padma_at is a date" do
      subject{ School.new(migrated_kshema_to_padma_at: Time.now)}
      its(:padma2_enabled?) { should be_true }
    end
  end
end

require 'rails_helper'

describe School do
  let(:school){create(:school)}
  before do
    school
  end
  it { should belong_to :federation }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
  it { should have_many :monthly_stats }

  #it_behaves_like 'it uses NucleoApi for schools' do
  #  let(:object){School.last || create(:school)}
  #  let(:klass){School}
  #end

  # PadmaAccounts
  it { should have_db_column :account_name }
  it { should allow_value(nil).for(:account_name)}
  it "should validate uniqueness of account_name" do
    create(:school, account_name: 'blah')
    s = FactoryBot.build(:school, account_name: 'blah')
    s.save
    expect(s.errors.keys).to include :account_name
  end
  
  describe "#padma_enabled?" do
    describe "if school has an account_name" do
      let(:school){create(:school, account_name: 'x')}
      describe "and connection to accounts-ws NOT available" do
        it "wont cache to cached_padma_enabled" do
          expect(school.cached_padma_enabled).to be_nil
          school.padma_enabled? 
          expect(school.cached_padma_enabled).to be_nil
        end
      end
      describe "and connection to accounts-ws is available" do
        before do
          allow(school).to receive(:account).and_return(PadmaAccount.new(enabled: true))
        end
        it "caches value co cached_padma_enabled" do
          expect(school.cached_padma_enabled).to be_nil
          school.padma_enabled? 
          expect(school.cached_padma_enabled).not_to be_nil
        end
      end
    end
  end

  describe "#sync_year_stats" do
    let(:school){create(:school)}
    before do
      allow_any_instance_of(SchoolMonthlyStat).to receive(:get_remote_value).and_return('1')
      allow(TeacherMonthlyStat).to receive(:get_remote_values).and_return([
          {full_name: 'Name', padma_username: 'username', value: '3'},
          {full_name: 'Name2', padma_username: 'username5', value: '3'}
                                                             ])
      allow(TeacherMonthlyStat).to receive(:calculate_local_value).and_return('1')
    end
    it "should create stats for each month for each stat name" do
      n = MonthlyStat::VALID_NAMES.size * 12
      n = n + TeacherMonthlyStat::STATS_BY_TEACHER.size * 2 * 12
      expect{school.sync_year_stats(2011)}.to change{school.monthly_stats.count}.by(n)
    end
    it "should update school#synced_at timestamp" do
      school.sync_year_stats(2011)
      expect(school.synced_at).to be_within(1.minute).of(Time.now)
    end
  end

  describe "#relative_students_count?" do
    subject{ school.relative_students_count? }
    context "if school has relative value and date" do
      let(:school){create(:school,
                          count_students_relative_to_value: 1,
                          count_students_relative_to_date: Date.today
                         )}
      it { should be_truthy }
    end
    context "if schools does NOT have relative value or date" do
      let(:school){create(:school)}
      it { should be_falsey }
    end
  end
end

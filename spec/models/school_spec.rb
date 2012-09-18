require 'spec_helper'

describe School do
  before do
    create(:school)
  end
  it { should belong_to :federation }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
  it { should have_many :monthly_stats }

  it_behaves_like 'it uses SchoolApi for schools' do
    let(:object){School.last || create(:school)}
    let(:klass){School}
  end

  # PadmaAccounts
  it { should have_db_column :account_name }
  it { should allow_value(nil).for(:account_name)}
  it { should validate_uniqueness_of(:account_name) }

  describe "#sync_year_stats" do
    let(:school){create(:school)}
    before do
      School.any_instance.stub(:fetch_stat).and_return('1')
    end
    it "should create stats for each month for each stat name" do
      n = MonthlyStat::VALID_NAMES.size * 12
      expect{school.sync_year_stats(2011)}.to change{school.monthly_stats.count}.by(n)
    end
  end
end

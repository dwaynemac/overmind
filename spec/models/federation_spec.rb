require 'rails_helper'

describe Federation do
  before do
    create(:federation)
  end
  it { should validate_uniqueness_of :name }
  it { should validate_presence_of :name }
  it { should have_many :schools }
  it { should have_many(:school_monthly_stats).through(:schools)}
  it { should have_many :users}

  it_behaves_like "it uses FederationApi" do
    let(:object){Federation.new}
    let(:klass){Federation}
  end

end

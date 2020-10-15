require 'rails_helper'

describe Federation do
  before do
    create(:federation)
  end
  it { should validate_uniqueness_of :name }
  it { should validate_presence_of :name }
  it { should respond_to :schools }
  it { should respond_to(:school_monthly_stats)}
  it { should respond_to :users}

  #it_behaves_like "it uses FederationApi" do
  #  let(:object){Federation.new}
  #  let(:klass){Federation}
  #end

end

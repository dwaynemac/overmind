require 'rails_helper'

shared_examples "receives params from url" do
  it "receives :year as string" do
    expect(controller.params[:year]).to eq "2014"
  end
  it "receives :month as string" do
    expect(controller.params[:month]).to eq "6"
  end
end

describe ReportsController do
  
  let!(:school){ create(:school, account_name: 'nunez') }

  let(:user){create(:user,role: 'admin')}
  before do
    sign_in(user)
    allow_any_instance_of(SyncRequest).to receive_message_chain(:delay, :start)
  end

  render_views

  describe "GET /schools/:id/marketing/:year/:month" do
    before do
      get :marketing_snapshot, school_id: 1, year: 2014, month: 6
    end
    it_behaves_like "receives params from url"
    it { should respond_with 200 }
  end

  describe "GET /schools/:id/pedagogic/:year/:month" do
    before do
      get :pedagogic_snapshot, school_id: 1, year: 2014, month: 6
    end
    it_behaves_like "receives params from url"
    it { should respond_with 200 }
  end

  describe "GET /schools/:account_name/pedagogic/:year/:month" do
    before do
      allow(school).to receive(:account).and_return(
        PadmaAccount.new(account_name: school.account_name))
      get :pedagogic_snapshot, school_id: school.account_name,
                               year: 2014,
                               month: 6
    end
    it_behaves_like "receives params from url"
    it { should respond_with 200 }
  end

end

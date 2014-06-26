require 'spec_helper'

describe ReportsController do

  let(:user){create(:user,role: 'admin')}
  before do
    PadmaAccount.any_instance.stub('padma2_enabled?').and_return(false)
    sign_in(user)
  end

  render_views

  describe "GET /schools/:id/marketing/:year/:month" do
    before do
      get :marketing_snapshot, school_id: 1, year: 2014, month: 6
    end
    it { should respond_with 200 }
  end
  describe "GET /schools/:id/pedagogic/:year/:month" do
    before do
      get :pedagogic_snapshot, school_id: 1, year: 2014, month: 6
    end
    it { should respond_with 200 }
  end

end

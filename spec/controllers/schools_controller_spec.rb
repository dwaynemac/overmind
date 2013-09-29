require 'spec_helper'

describe SchoolsController do

  before do
    PadmaAccount.any_instance.stub('padma2_enabled?').and_return(false)
  end

  context "for admin" do
    let(:user){create(:user,role: 'admin')}
    before do
      sign_in(user)
    end
    describe "#index" do
      before do
        get :index
      end
      it { should respond_with :success }
      it { should assign_to :schools }
    end
  end

  context "for user without role" do
    let(:user){create(:user,role: '', federation_id: 3)}
    before do
      create(:school, account_name: 'an-account', federation_id: 3)
      user.stub!(:padma_enabled?).and_return(true)
      user.stub!(:enabled_accounts).and_return([mock(name: 'an-account')])
      sign_in(user)
    end
  end

end

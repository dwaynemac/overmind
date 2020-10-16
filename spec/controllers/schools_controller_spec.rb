require 'rails_helper'

describe SchoolsController do


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
    describe "#show_by_nucleo_id" do
      describe "if school has nucleo_id" do
        let(:school){create(:school, nucleo_id: 1)}
        before do
          get :show_by_nucleo_id, nid: school.nucleo_id
        end
        it { should redirect_to school }
      end
      describe "if school doesnt have nucleo_id" do
        let!(:school){create(:school, nucleo_id: nil, account_name: 'xx-acname-xx')}
        before do
          allow(PadmaAccount).to receive(:find_by_nucleo_id).and_return PadmaAccount.new name: school.account_name
          get :show_by_nucleo_id, nid: 12
        end
        it { should redirect_to school }
        it "updates schools nucleo_id" do
          expect(school.reload.nucleo_id).to eq 12
        end
      end
    end
  end

  context "for user without role" do
    let(:user){create(:user,role: '', federation_id: 3)}
    before do
      create(:school, account_name: 'an-account', federation_id: 3)
      allow(user).to receive(:padma_enabled?).and_return(true)
      allow(user).to receive(:enabled_accounts).and_return([mock(name: 'an-account')])
      sign_in(user)
    end
  end
end

require 'spec_helper'

describe RankingsController do
  describe "for admin user" do
  let(:user){create(:user,role: 'admin')}
    before do
      PadmaAccount.any_instance.stub('padma2_enabled?').and_return(false)
      @fedone = create(:federation,id:1)
      @fedtwo = create(:federation,id:2)
      sign_in(user)
    end
    describe "#show" do

      render_views

      it "responds 200" do
        get :show
        should respond_with 200
      end

      it "allows to filter from all federations visible to user even when filtered" do
        get :show, ranking: { federation_ids: [1] }
        @fedone.should be_in assigns(:federations)
        @fedtwo.should be_in assigns(:federations)
      end
      
      describe "shows missing schools" do
        it "only includes those from federations selected in form" do
          yes = create(:school, federation_id: 1)
          no  = create(:school, federation_id: 2)
          get :show, ranking: { federation_ids: [1] }
          yes.should be_in assigns(:missing_schools)
        end
      end
    end
  end
end

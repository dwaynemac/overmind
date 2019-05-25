require 'spec_helper'

describe RankingsController, type: :controller do
  describe "for admin user" do
  let(:user){create(:user,role: 'admin')}
    before do
      allow(PadmaUser).to receive(:find).and_return(PadmaUser.new(username: user.username, current_account_name: "test-acc"))
      @fedone = create(:federation,id:1)
      @fedtwo = create(:federation,id:2)
      @school = create(:school, :account_name => 'test-acc')
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
        expect(@fedone).to be_in assigns(:federations)
        expect(@fedtwo).to be_in assigns(:federations)
      end
      
      describe "shows missing schools" do
        it "only includes those from federations selected in form" do
          yes = create(:school, federation_id: 1)
          no  = create(:school, federation_id: 2)
          get :show, ranking: { federation_ids: [1] }
          expect(yes).to be_in assigns(:missing_schools)
        end
      end
    end
  end
end

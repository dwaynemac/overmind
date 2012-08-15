require 'spec_helper'

describe UsersController do
  context "for admin" do
    let(:user){create(:user,role: 'admin')}
    before do
      sign_in(user)
    end
    describe "#index" do
      before { get :index }
      it { should respond_with :success }
      it { should assign_to :users }
    end
    describe "#create" do
      before do
        expect{post :create, user: attributes_for(:user)}.to change{User.count}.by(1)
      end
      it { should respond_with :redirect }
      it { should redirect_to User.last }
    end
    describe "#destroy" do
      let(:id){create(:user).id}
      before do
        expect{delete :destroy, id: id}.to change{User.count}.by(-1)
      end
      it { should redirect_to users_url }
    end
    describe "#update" do
      let(:user){create :user}
      before do
        put :update, id: user.id, user: attributes_for(:user, role: 'council')
      end
      it "should update user attributes" do
        user.role.should == 'council'
      end
    end
  end
end

require 'rails_helper'

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
      before do
        id = create(:user).id
        expect{delete :destroy, id: id}.to change{User.count}.by(-1)
      end
      it { should redirect_to users_url }
    end
    describe "#update" do
      before do
        @user = create :user
        put :update, id: @user.id, user: attributes_for(:user, role: 'council')
      end
      it "should update user attributes" do
        @user.reload
        @user.role.should == 'council'
      end
    end
  end
end

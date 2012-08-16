require 'spec_helper'

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

  end
end

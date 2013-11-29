require 'spec_helper'

describe SyncRequestsController do

  before do
    @school = School.first||create(:school) 
    
    @user = FactoryGirl.create(:user, role: 'admin')
    pu = PadmaUser.new(username: @user.username)
    User.any_instance.stub(:padma_enabled?).and_return true
    User.any_instance.stub(:padma).and_return pu

    sign_in(@user)
  end

  describe "#create" do
    def do_request
      post :create, school_id: @school.id, sync_request: { year: 2013, priority: 10 }
    end

    it "creates a new sync_request" do
      expect{do_request}.to change{SyncRequest.count}.by 1
    end

    it "redirects to schools#show" do
      do_request
      response.should redirect_to school_path(@school.id, year: 2013)
    end
  end

  describe "#update" do
    let(:sr){create(:sync_request)}
    it "changes priorty value" do
      sr.update_attribute :priority, 2
      put :update, school_id: sr.school_id, id: sr.id, sync_request: { priority: 10 }
      sr.reload.priority.should == 10
    end
  end

end

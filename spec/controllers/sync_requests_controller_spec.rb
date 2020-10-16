require 'rails_helper'

describe SyncRequestsController do

  before do
    @school = School.first||create(:school) 
    
    @user = FactoryBot.create(:user, role: 'admin')
    pu = PadmaUser.new(username: @user.username)
    allow_any_instance_of(User).to receive(:padma_enabled?).and_return true
    allow_any_instance_of(User).to receive(:padma).and_return pu

    pa = PadmaAccount.new
    allow_any_instance_of(User).to receive(:current_account).and_return pa

    sign_in(@user)
  end

  describe "#create" do
    context "when month is specified" do
      def do_request
        post :create, school_id: @school.id, sync_request: { year: 2013, month: 3, priority: 10 }
      end
      it "creates a new sync_request" do
        expect{do_request}.to change{SyncRequest.count}.by 1
      end

      it "redirects to schools#show" do
        do_request
        expect(response).to redirect_to school_path(@school.id, year: 2013)
      end
    end
    context "when month is not specified" do
      context "if year is current" do
        def do_request
          post :create, school_id: @school.id, sync_request: { year: Time.zone.now.year, priority: 10 }
        end
        it "creates sync_request for past and current months" do
          expect{do_request}.to change{SyncRequest.count}.by Time.zone.now.month
        end
      end
      context "if year is past" do
        def do_request
          post :create, school_id: @school.id, sync_request: { year: Time.zone.now.year-1, priority: 10 }
        end
        it "creates sync_request for each month" do
          expect{do_request}.to change{SyncRequest.count}.by 12
        end
      end
    end
  end

  describe "#update" do
    let(:sr){create(:sync_request)}
    it "changes priorty value" do
      sr.update_attribute :priority, 2
      put :update, school_id: sr.school_id, id: sr.id, sync_request: { priority: 10 }
      expect(sr.reload.priority).to eq 10
    end
  end

end

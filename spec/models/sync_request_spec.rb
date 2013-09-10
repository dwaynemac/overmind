require 'spec_helper'

describe SyncRequest do
  let(:sync_request){create(:sync_request)}

  it { should validate_presence_of :school_id }
  it { should validate_presence_of :year }

  describe "on create" do
    it "defaults state to :ready" do
      sr = build(:sync_request)
      sr.save
      sr.reload.state.should == 'ready'
    end
    it "defaults synced_upto to 0" do
      sr = build(:sync_request)
      sr.save
      sr.reload.synced_upto.should == 0
    end
  end

  def should_call_to_sync_month(n)
    sync_request.school.should_receive(:sync_school_month_stats).with(
      sync_request.year,
      n,
      {update_existing: true, skip_synced_at_setting: true}
    )
    sync_request.school.should_receive(:sync_teacher_monthly_stats).with(sync_request.year,n)
  end

  def should_not_call_to_sync_month(n)
    sync_request.school.should_not_receive(:sync_school_month_stats).with(sync_request.year,n,
      {update_existing: true}                                                                     
    )
    sync_request.school.should_not_receive(:sync_teacher_monthly_stats).with(sync_request.year,n)
  end

  describe "#start" do
    before do
      sync_request
    end

    describe "first run" do
      it "syncs month 1" do
        should_call_to_sync_month(1)
        sync_request.start
      end
      it "wont sync month 2" do
        should_not_call_to_sync_month(2)
        sync_request.start
      end
      it "sets synced_upto to 1" do
        should_call_to_sync_month(1) # here for stubs
        sync_request.start
        sync_request.synced_upto.should == 1
      end
      it "sets state to :paused" do
        should_call_to_sync_month(1) # here for stubs
        sync_request.start
        sync_request.state.should == :paused
      end
    end

    describe "second run" do
      it "wont sync month 1"
      it "syncs month 2"
      it "wont sync month 3"
      it "sets synced_upto to 2"
      it "sets state to :paused"
    end

    describe "last run" do
      describe "when syncing current year" do
        it "syncs current month"
        it "sets synced_upto to current_month"
        it "sets state to finish"
      end
      describe "when syncing preivous years" do
        it "syncs month 12"
        it "sets synced_upto to 12"
        it "sets state to :finished" do
          sync_request.school.should_receive(:sync_year_stats).with(sync_request.year, update_existing: true).and_return(true)
          sync_request.school.update_attribute :synced_at, Time.now
          sync_request.start
          sync_request.state.should == 'finished'
        end
      end
    end
  end
end

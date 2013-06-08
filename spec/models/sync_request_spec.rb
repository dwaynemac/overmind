require 'spec_helper'

describe SyncRequest do

  it { should validate_presence_of :school_id }
  it { should validate_presence_of :year }

  it "should default state to :ready" do
    sr = build(:sync_request)
    sr.save
    sr.reload.state.should == 'ready'
  end

  describe "#start" do
    let(:sync_request){create(:sync_request)}
    it "should call school.sync_year_stats(year)" do
      sync_request.school.should_receive(:sync_year_stats).with(sync_request.year, update_existing: true)
      sync_request.start
    end
    it "should set state to finished if sync successfull" do
      sync_request.school.should_receive(:sync_year_stats).with(sync_request.year, update_existing: true).and_return(true)
      sync_request.school.update_attribute :synced_at, Time.now
      sync_request.start
      sync_request.state.should == 'finished'
    end
    it "should set state to failed if sync fails" do
      sync_request.school.should_receive(:sync_year_stats).with(sync_request.year, update_existing: true).and_return(false)
      sync_request.start
      sync_request.state.should == 'failed'
    end
  end
end

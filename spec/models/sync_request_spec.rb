require 'spec_helper'

describe SyncRequest do
  let(:sync_request){create(:sync_request)}

  it { should validate_presence_of :school_id }
  it { should validate_presence_of :year }

  describe ".prioritized" do
    it "orders with highest priority first" do
      s = create(:sync_request, priority: 9)
      t = create(:sync_request, priority: 8)
      l = create(:sync_request, priority: nil)
      f = create(:sync_request, priority: 10)
      SyncRequest.prioritized.should == [f,s,t,l]
    end
  end

  describe "on create" do
    it "defaults priority to 0" do
      sr = build(:sync_request)
      sr.priority.should be_nil
      sr.save
      sr.reload.priority.should == 0
    end
    it "defaults state to :ready" do
      sr = build(:sync_request)
      sr.should be_valid
      sr.save
      sr.reload.should be_ready # ready? == true
    end
    it "defaults synced_upto to 0" do
      sr = build(:sync_request)
      sr.save
      sr.reload.synced_upto.should == 0
    end
    it "checks there is no pending request for same school and same year" do
      sr = create(:sync_request)
      new_sr_invalid = build(:sync_request, school_id: sr.id, year: sr.year)
      new_sr_invalid.should_not be_valid
      new_sr_valid = build(:sync_request, school_id: sr.id, year: sr.year+1)
      new_sr_valid.should be_valid
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
      it "sets state to paused" do
        should_call_to_sync_month(1) # here for stubs
        sync_request.start
        sync_request.reload.should be_paused # paused? == true
      end
    end

    describe "second run" do
      before do
        should_call_to_sync_month(1) # here for stubs
        sync_request.start # first run
      end
      it "wont sync month 1" do
        should_not_call_to_sync_month(1)
        sync_request.start
      end
      it "syncs month 2" do
        should_call_to_sync_month(2)
        sync_request.start
      end
      it "wont sync month 3" do
        should_not_call_to_sync_month(3)
        sync_request.start
      end
      it "sets synced_upto to 2" do
        should_call_to_sync_month(2) # here for stubs
        sync_request.start
        sync_request.reload.synced_upto.should == 2
      end
      it "sets state to paused" do
        should_call_to_sync_month(2) # here for stubs
        sync_request.start
        sync_request.reload.should be_paused
      end
    end

    describe "when syncing current year" do
      let(:now){Time.parse("24 Apr 2013")}
      before do
        Time.stub!(:now).and_return(now)
        sync_request.update_attribute :year, Time.now.year
      end
      describe "4th (current month) run" do
        before do
          (1...Time.now.month).each do |i|
            should_call_to_sync_month(i)
            sync_request.start
          end
        end
        it "syncs current month" do
          should_call_to_sync_month(Time.now.month)
          sync_request.start
        end
        it "sets synced_upto to current_month" do
          should_call_to_sync_month(Time.now.month)
          sync_request.start
          sync_request.reload.synced_upto.should == Time.now.month
        end
        it "sets state to finished" do
          should_call_to_sync_month(Time.now.month)
          sync_request.start
          sync_request.reload.should be_finished # finished? == true
        end
        it "sets synced_at in school" do
          sync_request
          should_call_to_sync_month(Time.now.month)
          expect{sync_request.start}.to change{sync_request.school.synced_at}
        end
        it "caches student count in school" do
          sync_request.school.should_receive(:cache_last_student_count)
          should_call_to_sync_month(Time.now.month) # for mocking
          sync_request.start
          sync_request.reload.should be_finished # finished? == true
        end
      end
      describe "5th run (next month)" do
        before do
          (1..Time.now.month).each do |i|
            should_call_to_sync_month(i)
            sync_request.start
          end
        end
        it "wont sync" do
          should_not_call_to_sync_month(Time.now.month+1)
          sync_request.start
        end
        it "wont change synced_upto" do
          expect{sync_request.start}.not_to change{sync_request.synced_upto}
        end
        it "wont change state" do
          expect{sync_request.start}.not_to change{sync_request.state}
        end
      end
    end
    describe "when syncing preivous years" do
      before do
        sync_request.update_attribute :year, Time.now.year - 1
      end
      describe "12th run" do
        before do
          (1...12).each do |i|
            should_call_to_sync_month(i)
            sync_request.start
          end
        end
        it "syncs month 12" do
          should_call_to_sync_month(12)
          sync_request.start
        end
        it "sets synced_upto to 12" do
          should_call_to_sync_month(12)
          sync_request.start
          sync_request.reload.synced_upto.should == 12
        end
        it "sets state to :finished" do
          should_call_to_sync_month(12)
          sync_request.start
          sync_request.reload.should be_finished # finished? == true
        end
        it "sets synced_at in school" do
          sync_request
          should_call_to_sync_month(12) # for mocking
          expect{sync_request.start}.to change{sync_request.school.synced_at}
        end
        it "caches student count in school" do
          sync_request.school.should_receive(:cache_last_student_count)
          should_call_to_sync_month(12)
          sync_request.start
          sync_request.reload.should be_finished # finished? == true
        end
      end
      describe "13th run" do
        before do
          (1..12).each do |i|
            should_call_to_sync_month(i)
            sync_request.start
          end
        end
        it "wont sync" do
          should_not_call_to_sync_month(Time.now.month+1)
          sync_request.start
        end
        it "wont change synced_upto" do
          expect{sync_request.start}.not_to change{sync_request.synced_upto}
        end
        it "wont change state" do
          expect{sync_request.start}.not_to change{sync_request.state}
        end
      end
    end
  end


  describe "#progress" do
    describe "for current year and current month 4" do
      let(:now){Time.parse("24 Apr 2013")}
      before do
        Time.stub!(:now).and_return(now)
        sync_request.year = Time.now.year
      end
      it "synced_upto 0 returns 0" do
        sync_request.synced_upto = 0
        sync_request.progress.should == 0
      end
      it "synced_upto 1 returns 25" do
        sync_request.synced_upto = 1
        sync_request.progress.should == 25
      end
      it "synced_upto 4 returns 100" do
        sync_request.synced_upto = 4
        sync_request.progress.should == 100
      end
    end
    describe "for previous years" do
      before do
        sync_request.year = Time.now.year - 1
      end
      it "synced_upto 0 returns 0" do
        sync_request.synced_upto = 0
        sync_request.progress.should == 0
      end
      it "synced_upto 1 returns 8" do
        sync_request.synced_upto = 1
        sync_request.progress.should == 8
      end
      it "synced_upto 12 returns 100" do
        sync_request.synced_upto = 12
        sync_request.progress.should == 100
      end
    end
  end

end

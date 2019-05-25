require 'spec_helper'

describe SyncRequest do
  let(:sync_request){create(:sync_request)}

  describe "validates presence of" do
    before { sync_request }

    it "school_id" do
      should validate_presence_of :school_id
    end
    it "year" do
      should validate_presence_of :year
    end
    it "month" do
      should validate_presence_of :year
    end
  end

  [0,13].each do |m|
    it { should_not allow_value(m).for(:month) }
  end

  [1,6,12].each do |m|
    it { should allow_value(m).for(:month) }
  end

  describe ".prioritized" do
    it "orders with highest priority first" do
      s = create(:sync_request, priority: 9)
      t = create(:sync_request, priority: 8)
      l = create(:sync_request, priority: nil)
      f = create(:sync_request, priority: 10)
      expect(SyncRequest.prioritized).to be == [f,s,t,l]
    end
  end

  describe "on create" do
    it "defaults priority to 0" do
      sr = build(:sync_request)
      expect(sr.priority).to be_nil
      sr.save
      expect(sr.reload.priority).to be == 0
    end
    it "defaults state to :ready" do
      sr = build(:sync_request)
      expect(sr).to be_valid
      sr.save
      expect(sr.reload).to be_ready # ready? == true
    end
    it "defaults month to 1" do
      sr = build(:sync_request, month: nil)
      sr.save!
      expect(sr.reload.month).to eq 1
    end
    describe "validates only one request per school per month-year" do
      let!(:sr){create(:sync_request)}
      it "wont allow same school, month, year" do
        new_sr = build(:sync_request, school_id: sr.id, year: sr.year, month: sr.month)
        expect(new_sr).not_to be_valid
      end
      it "allows same month, year, diff school" do
        new_sr = build(:sync_request, school_id: create(:school).id, year: sr.year, month: sr.month)
        expect(new_sr).to be_valid
      end
      it "allows same school and month diff year" do
        new_sr = build(:sync_request, school_id: sr.id, year: sr.year+1, month: sr.month)
        expect(new_sr).to be_valid
      end
      it "allows same school and year diff month" do
        new_sr = build(:sync_request, school_id: sr.id, year: sr.year, month: sr.month+1)
        expect(new_sr).to be_valid
      end
    end
  end
=begin
  describe "#start" do
    it "sets state to finished" do
      sync_request.start
      expect(sync_request.reload).to be_finished
    end

    describe "if exception is raised" do
      before do
        allow_any_instance_of(SyncRequest).to receive(:syncable_month?).and_raise "hell"
      end
      it "catches it" do
        expect{sync_request.start}.not_to raise_exception
      end
      it "sets :state to 'failed'" do
        sync_request.start
        expect(sync_request.state).to == 'failed'
      end
    end

    describe "if filter_by_event is nil" do
      before do
        sync_request.update_attribute(:filter_by_event,nil)
      end
      it "syncs all stats" do
        MonthlyStat::VALID_NAMES.each do |sn|
          expect(SchoolMonthlyStat).to receive('sync_from_service!')
                           .with(anything,sn,anything)
        end
        sync_request.start
      end
    end
    describe "if filter_by_event is ''" do
      before do
        sync_request.update_attribute(:filter_by_event,'')
      end
      it "syncs all stats" do
        MonthlyStat::VALID_NAMES.each do |sn|
          expect(SchoolMonthlyStat).to receive('sync_from_service!')
                           .with(anything,sn,anything)
        end
        sync_request.start
      end
    end
    describe "if filter_by_event is 'communication" do
      before do
        sync_request.update_attribute(:filter_by_event,'communication')
      end
      it "syncs all stats" do
        SchoolMonthlyStat.stats_for_event('communication').each do |sn|
          expect(SchoolMonthlyStat).to receive('sync_from_service!')
                           .with(anything,sn,anything)
        end
        sync_request.start
      end
    end
  end
=end
  describe "#nigh_only?" do
    it "returns true for priority nil job" do
      sync_request.priority = nil
      expect(sync_request).to be_night_only
    end
    it "returns true for priority 1 job" do
      sync_request.priority = 1
      expect(sync_request).to be_night_only
    end
    it "returns false for priority 5 job" do
      sync_request.priority = 5
      expect(sync_request).not_to be_night_only
    end
    it "returns false for priority 6 job" do
      sync_request.priority = 6
      expect(sync_request).not_to be_night_only
    end
    it "returns false for priority 10 job" do
      sync_request.priority = 10
      expect(sync_request).not_to be_night_only
    end
  end
end

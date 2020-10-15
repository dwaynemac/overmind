require 'spec_helper'
include AuthHelper

describe MessageDoorController do

  def request(key_name,sk,data)
    login_user
    post :catch,
         key_name: key_name,
         secret_key: sk,
         data: ActiveSupport::JSON.encode(data)
  end

  before do
    SyncRequest.destroy_all
  end

  let!(:recoleta){ create(:school, account_name: 'recoleta') }

  describe "catch" do
    context "with valid secret_key" do
      let(:sk){'secret'}
      context "if sync already queued" do
        let(:key_name){ 'subscription_change' }
        let(:data){{type: 'Enrollment',contact_id: '1234',
                    changed_at: '2014-8-23',
                    account_name: 'recoleta',
        }}
        before do
          SyncRequest.create!( school_id: recoleta.id,
                               year: 2014,
                               month: 8)
        end
        it "wont queue another" do
          expect{ request(key_name,sk,data) }.not_to change {
            SyncRequest.count
          }
        end
      end

      %W(subscription_change destroyed_subscription_change).each do |key_name|
        context "for key_name #{key_name}" do
          let(:key_name){key_name}
          let(:data){{type: 'Enrollment',contact_id: '1234',
                      changed_at: '2014-8-23',
                      account_name: 'recoleta',
          }}
          before { request(key_name,sk,data) }
          it "syncs changed_at month" do
            ref_date = data[:changed_at].to_date
            sr = SyncRequest.last
            expect(sr).not_to be_nil
            expect(sr.year).to eq ref_date.year
            expect(sr.month).to eq ref_date.month
          end
          it "syncs account_name" do
            ref_date = data[:changed_at].to_date
            sr = SyncRequest.last
            expect(sr).not_to be_nil
            expect(sr.school).to eq recoleta
          end
          it { should respond_with 200 }
        end
      end
      context "for key_name updated_subscription_change" do
        let(:key_name){ 'updated_subscription_change' }
        before { request(key_name,sk,data) }
        let(:data){{type: 'Enrollment',contact_id: '1234',
                    changed_at: '2014-8-23',
                    changed_at_was: '2014-9-1',
                    account_name: 'recoleta',
        }}
        it "syncs changed_at month" do
          ref_date = data[:changed_at].to_date
          sr = SyncRequest.where(year: ref_date.year,
                                 month: ref_date.month)
          expect(sr).not_to be_empty
        end
        it "syncs changed_at_was month" do
          ref_date = data[:changed_at_was].to_date
          sr = SyncRequest.where(year: ref_date.year,
                                 month: ref_date.month)
          expect(sr).not_to be_empty
        end
        it "syncs account_name" do
          sr = SyncRequest.where(school_id: recoleta.id)
          expect(sr).not_to be_empty
        end
        it { should respond_with 200 }
      end
      %W(communication destroyed_communication).each do |key_name|
        context "for key_name #{key_name}" do
          let(:key_name){key_name}
          let(:data){{type: 'Communication',contact_id: '1234',
                      communicated_at: '2014-8-23',
                      account_name: 'recoleta',
          }}
          before { request(key_name,sk,data) }
          it "syncs communicated_at month" do
            ref_date = data[:communicated_at].to_date
            sr = SyncRequest.where(year: ref_date.year,
                                   month: ref_date.month)
            expect(sr).not_to be_empty
          end
          it "syncs account_name" do
            sr = SyncRequest.where(school_id: recoleta.id)
            expect(sr).not_to be_empty
          end
          it { should respond_with 200 }
        end
      end
      context "for key_name updated_communication" do
        let(:key_name){ 'updated_communication' }
        let(:data){{type: 'Communication',contact_id: '1234',
                    communicated_at: '2014-8-23',
                    communicated_at_was: '2014-9-1',
                    account_name: 'recoleta',
        }}
        before { request(key_name,sk,data) }
        it "syncs communicated_at_was month" do
          ref_date = data[:communicated_at_was].to_date
          sr = SyncRequest.where(year: ref_date.year,
                                 month: ref_date.month)
          expect(sr).not_to be_empty
        end
        it "syncs communicated_at month" do
          ref_date = data[:communicated_at].to_date
          sr = SyncRequest.where(year: ref_date.year,
                                 month: ref_date.month)
          expect(sr).not_to be_empty
        end
        it "syncs account_name" do
          sr = SyncRequest.where(school_id: recoleta.id)
          expect(sr).not_to be_empty
        end
        it { should respond_with 200 }
      end
      context "for other key_names" do
        let(:key_name){ 'asd' }
        let(:data){{}}
        before { request(key_name,sk,data) }
        it "does nothing" do
          expect(SyncRequest.count).to eq 0
        end
        it { should respond_with 400 }
      end
      context "if syncing current month" do
        let(:key_name){ 'communication' }
        let(:data){{type: 'Communication',contact_id: '1234',
                    communicated_at: Date.today.to_s,
                    account_name: 'recoleta',
        }}
        before { request(key_name,sk,data) }
        it "queues with priority 12" do
          expect(SyncRequest.last.priority).to eq 12
        end
      end
      context "if syncing previous months" do
        let(:key_name){ 'communication' }
        let(:data){{type: 'Communication',contact_id: '1234',
                    communicated_at: 2.months.ago.to_date.to_s,
                    account_name: 'recoleta',
        }}
        before { request(key_name,sk,data) }
        it "queues with priority 4 (night only)" do
          expect(SyncRequest.last.priority).to eq 4
        end
      end
      context "if account_name not in data" do
        let(:key_name){ 'communication' }
        let(:data){{type: 'Communication',contact_id: '1234',
                    communicated_at: 2.months.ago.to_date.to_s
        }}
        before { request(key_name,sk,data) }
        it "does nothing" do
          expect(SyncRequest.count).to eq 0
        end
      end
      context "if no reference date available in data" do
        let(:key_name){ 'communication' }
        let(:data){{type: 'Communication',contact_id: '1234'}}
        before { request(key_name,sk,data) }
        it "does nothing" do
          expect(SyncRequest.count).to eq 0
        end
      end
    end
    context "with INvalid secret key" do
      let(:sk){'invalid'}
      let(:key_name){'communication'}
      let(:data){{}}
      before { request(key_name,sk,data) }
      it { should respond_with 401 }
    end
  end
end

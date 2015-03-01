require 'spec_helper'

describe MessageDoorController do

  def request(key_name,sk,data)
    post :catch,
         key_name: key_name,
         secret_key: sk,
         data: ActiveSupport::JSON.encode(data)
  end

  describe "catch" do
    context "with valid secret_key" do
      let(:sk){ENV['messaging_secret']}
      %W(subscription_change destroyed_subscription_change).each do |key_name|
        context "for key_name #{key_name}" do
          let(:key_name){key_name}
          let(:data){{type: 'Enrollment',contact_id: '1234',
                      changed_at: '2014-8-23',
                      account_name: 'recoleta',
          }}
          before { request(key_name,sk,data) }
          it "syncs changed_at month"
          it "syncs account_name"
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
        it "syncs changed_at_was month"
        it "syncs changed_at month"
        it "syncs account_name"
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
          it "syncs communicated_at month"
          it "syncs account_name"
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
        it "syncs communicated_at_was month"
        it "syncs communicated_at month"
        it "syncs account_name"
        it { should respond_with 200 }
      end
      context "for other key_names" do
        let(:key_name){ 'asd' }
        let(:data){{}}
        before { request(key_name,sk,data) }
        it "does nothing"
        it { should respond_with 200 }
      end
      context "if syncing current month" do
        let(:data){{type: 'Communication',contact_id: '1234',
                    communicated_at: Date.today.to_s,
                    account_name: 'recoleta',
        }}
        before { request(key_name,sk,data) }
        it "queues with priority 12"
      end
      context "if syncing previous months" do
        let(:data){{type: 'Communication',contact_id: '1234',
                    communicated_at: 2.months.ago.to_data.to_s,
                    account_name: 'recoleta',
        }}
        before { request(key_name,sk,data) }
        it "queues with priority 4 (night only)"
      end
      context "if account_name not in data" do
        let(:data){{type: 'Communication',contact_id: '1234',
                    communicated_at: 2.months.ago.to_data.to_s
        }}
        before { request(key_name,sk,data) }
        it "does nothing"
      end
      context "if no reference date available in data" do
        let(:data){{type: 'Communication',contact_id: '1234'}}
        before { request(key_name,sk,data) }
        it "does nothing"
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

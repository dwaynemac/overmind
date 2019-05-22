require 'spec_helper'

describe Api::V0::SyncRequestsController, type: :controller do
  describe "#pause_all" do
    let(:sr){create(:sync_request)}
    it "changes state running to paused" do
      sr.update_attribute :state, 'running'
      req_with_key :post, :pause_all
      expect(sr.reload.state).to eq 'paused'
    end
    it "wont change state ready" do
      sr.update_attribute :state, 'ready'
      req_with_key :post, :pause_all
      expect(sr.reload.state).to eq 'ready'
    end
  end

  def req_with_key(verb, action, args={})
    args.merge!({api_key: Api::V0::ApiController::KEY})
    self.send(verb, action, args)
  end
end

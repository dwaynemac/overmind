require 'spec_helper'

describe Api::V0::MonthlyStatsController do

  describe "#show" do
    context "with api_key" do
      before { req_with_key :get, :show, id: 123  }
      it { should respond_with 200 }

    end
    context "without api_key" do
      before { get :show, id: 123 }
      it { should respond_with 401 }
    end
  end

  def req_with_key(verb, action, args)
    args.merge!({api_key: Api::V0::ApiController::KEY})
    self.send(verb, action, args)
  end

end

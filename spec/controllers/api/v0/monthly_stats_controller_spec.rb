require 'spec_helper'

describe Api::V0::MonthlyStatsController do
  before do
    create(:school, account_name: 'account-name')
  end
  let(:a_monthly_stat){create(:monthly_stat, name: :students, ref_date: Date.civil(2012,10,31), account_name: 'account-name', value: 3)}

  describe "#create" do
    context "with existing MonthlyStat (name, ref_date, account)" do
      before do
        a_monthly_stat # creates
      end
      it "updates stat" do
        expect{req_with_key :post, :create, monthly_stat: {name: 'students', ref_date: Date.civil(2012,10,31).to_s, account_name: 'account-name', value: 4}}.to_not change{MonthlyStat.count}
        a_monthly_stat.reload.value.should == 4
      end
    end
    context "with non-existing MonthlyStat" do
      it "creates stat" do
        expect{
          req_with_key :post, :create, monthly_stat: {name: 'students', ref_date: Date.civil(2012,10,31).to_s, account_name: 'account-name', value: 4}
        }.to change{MonthlyStat.count}.by 1
        MonthlyStat.last.value.should == 4
      end
    end
  end

  describe "#show" do
    context "with api_key" do
      before { req_with_key :get, :show, id: a_monthly_stat.id  }
      it { should respond_with 200 }

    end
    context "without api_key" do
      before { get :show, id: a_monthly_stat.id }
      it { should respond_with 401 }
    end
  end

  def req_with_key(verb, action, args)
    args.merge!({api_key: Api::V0::ApiController::KEY})
    self.send(verb, action, args)
  end

end

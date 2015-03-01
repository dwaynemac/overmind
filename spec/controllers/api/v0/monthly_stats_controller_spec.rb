require 'spec_helper'

describe Api::V0::MonthlyStatsController do
  before do
    create(:school, account_name: 'account-name')
  end
  let(:a_monthly_stat){create(:monthly_stat,
                              name: :students,
                              ref_date: Date.civil(2012,10,31),
                              service: 'a-service',
                              account_name: 'account-name',
                              value: 3)}

  describe "#create" do
    context "with teacher_username dwayne" do
      context "with existing MonthlyStat (name, ref_date, account, teacher_username)" do
        let!(:teacher){ create(:teacher, username: 'dwayne') }
        let!(:teacher_stat){create(:teacher_monthly_stat,
                              name: :students,
                              ref_date: Date.civil(2012,10,31),
                              service: 'a-service',
                              account_name: 'account-name',
                              teacher_id: teacher.id,
                              value: 3)}
        it "updates stat value" do
          expect{req_with_key :post, :create,
                              monthly_stat: {name: 'students',
                                             ref_date: Date.civil(2012,10,31).to_s,
                                             account_name: 'account-name',
                                             teacher_username: 'dwayne',
                                             value: 4}}.to_not change{MonthlyStat.count}
          teacher_stat.reload.value.should == 4
        end
        it "updates stat service" do
          expect{req_with_key :post, :create, monthly_stat: {service: 'new-service',
                                                             name: 'students',
                                                             ref_date: Date.civil(2012,10,31).to_s,
                                                             account_name: 'account-name',
                                                             teacher_username: 'dwayne',
                                                             value: 4}}.to_not change{MonthlyStat.count}
          teacher_stat.reload.service.should == 'new-service'
        end
      end
      context "with non-existing MonthlyStat" do
        before do
          a_monthly_stat # create a similar one, but without teacher
        end
        it "creates stat" do
          expect{
            req_with_key :post, :create, monthly_stat: {name: 'students',
                                                        ref_date: Date.civil(2012,10,31).to_s,
                                                        account_name: 'account-name',
                                                        teacher_username: 'dwayne',
                                                        value: 4}
          }.to change{MonthlyStat.count}.by 1
          MonthlyStat.last.value.should == 4
          TeacherMonthlyStat.last.teacher.username.should == 'dwayne'
        end
      end
    end
    context "with teacher_username nil" do
      context "with existing MonthlyStat (name, ref_date, account, teacher_username)" do
        before do
          a_monthly_stat # creates
        end
        it "updates stat value" do
          expect{req_with_key :post, :create,
                              monthly_stat: {name: 'students',
                                             ref_date: Date.civil(2012,10,31).to_s,
                                             account_name: 'account-name',
                                             value: 4}}.to_not change{MonthlyStat.count}
          a_monthly_stat.reload.value.should == 4
        end
        it "updates stat service" do
          expect{req_with_key :post, :create, monthly_stat: {service: 'new-service',
                                                             name: 'students',
                                                             ref_date: Date.civil(2012,10,31).to_s,
                                                             account_name: 'account-name',
                                                             value: 4}}.to_not change{MonthlyStat.count}
          a_monthly_stat.reload.service.should == 'new-service'
        end
      end
      context "with non-existing MonthlyStat" do
        it "creates stat" do
          expect{
            req_with_key :post, :create, monthly_stat: {name: 'students',
                                                        ref_date: Date.civil(2012,10,31).to_s,
                                                        account_name: 'account-name',
                                                        value: 4}
          }.to change{MonthlyStat.count}.by 1
          MonthlyStat.last.value.should == 4
        end
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

require 'spec_helper'

describe Ability do

  let(:ability){Ability.new(user)}

  describe "admin" do
    let(:federation){create(:federation)}
    let(:user){create(:user,role: 'admin', federation: federation)}
    it "should be able to manage all" do
      it_can(:manage,:all)
    end
    it "can read all federations" do
      3.times{create(:federation)}
      ability.federations.count.should == 4
    end
  end

  describe "council" do
    let(:user){create(:user,role: 'council')}
    before do
      pu = PadmaUser.new
      #expect user.to receive_message_chain(:user, :padma_accounts, :map).and_return(["name"])
      user.should_receive(:user).at_least(1).times.and_return(pu)
      pu.should_receive(:padma_accounts).at_least(1).times.and_return([PadmaAccount.new(name: "first")])
    end
    it "should NOT be able to manage all" do
      it_cannot(:manage,:all)
    end
    it "can read all federations" do
      it_can(:read,Federation)
    end
    it "can read all schools" do
      it_can(:read,School)
    end
    it "can read all monthly values" do
      it_can(:read,MonthlyStat)
    end
    it "can read ranking" do
      it_can(:read,Ranking)
    end
  end

  describe "president" do
    let(:user){create(:user, role: 'president')}
    it "should NOT be able to manage all" do
      it_cannot(:manage,:all)
    end
    context "in a federation" do
      let(:fed){create(:federation)}
      before do
        user.update_attribute(:federation_id, fed.id)
      end
      it "should be able to read his federation" do
        it_can(:read,fed)
      end
      it "should NOT be able to read other federation" do
        it_cannot(:read,create(:federation))
      end
      it "should be able to read schools from his federation" do
        School.delete_all
        create(:school, federation: create(:federation))
        3.times{create(:school, federation: fed)}
        School.accessible_by(ability).count.should == 3
        it_can(:read,School.last)
      end
      it "should NOT be able to read OTHER federation stats" do
        ms = create(:monthly_stat, school: create(:school, federation: create(:federation)))
        it_cannot(:read,ms)
      end
      it "should be able to read HIS federation stats" do
        ms = create(:monthly_stat, school: create(:school, federation: fed))
        it_can(:read,ms)
      end
    end
  end

  describe "without role" do
    let(:user){create(:user)}
    it "should NOT be able to manage all" do
      it_cannot(:manage,:all)
    end
    context "without padma_accounts" do
      before do
        user.stub!(:enabled_accounts).and_return([])
      end
      context "in a federation" do
        let(:fed){create(:federation)}
        before do
          user.update_attribute(:federation_id, fed.id)
        end
        it "should not be able to read his federation" do
          it_cannot(:read,fed)
        end
        it "should NOT be able to read other federation" do
          it_cannot(:read,create(:federation))
        end
        it "should NOT be able to read schools from his federation" do
          create(:school)
          3.times{create(:school, federation: fed)}
          it_cannot(:read,School.last)
        end
        it "should NOT be able to read OTHER federation stats" do
          ms = create(:monthly_stat, school: create(:school, federation: create(:federation)))
          it_cannot(:read,ms)
        end
        it "should NOT be able to read HIS federation stats" do
          ms = create(:monthly_stat, school: create(:school, federation: fed))
          it_cannot(:read,ms)
        end
      end
    end
    context "with padma_accounts" do
      let(:fed){create(:federation)}
      let(:school){create(:school, account_name: 'this-account', federation: fed)}
      before do
        school
        pa = PadmaAccount.new(name: 'this-account')
        user.stub!(:current_account).and_return pa
        user.stub!(:enabled_accounts).and_return([pa])
        user.padma_enabled?.should be_true
      end
      before do
        user.update_attribute(:federation_id, fed.id)
      end
      it "should be able to read his federation" do
        it_can(:read,fed)
      end
      it "should NOT be able to read other federation" do
        it_cannot(:read,create(:federation))
      end
      it "should NOT be able to read other schools from his federation" do
        3.times{create(:school, federation: fed)}
        it_cannot(:read,School.last)
        School.accessible_by(ability).count.should == 1
      end
      it "should be able to read his school" do
        it_can(:read, school)
        School.accessible_by(ability).count.should == 1
      end
      it "should NOT be able to read OTHER federation stats" do
        ms = create(:monthly_stat, school: create(:school, federation: create(:federation)))
        it_cannot(:read,ms)
      end
      it "should be able to read HIS federation stats" do
        ms = create(:monthly_stat, school: school)
        it_can(:read,ms)
      end
    end
  end
  
  def it_can(action,target)
    ability.can?(action,target).should be_true
  end

  def it_cannot(action,target)
    ability.can?(action,target).should be_false
  end

end

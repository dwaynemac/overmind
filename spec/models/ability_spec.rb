require 'spec_helper'

describe Ability do
  let(:ability){Ability.new(user)}
  describe "admin" do
    let(:user){create(:user,role: 'admin')}
    it "should be able to manage all" do
      ability.can?(:manage,:all).should be_true
    end
    it "can read all federations" do
      3.times{create(:federation)}
      Federation.accessible_by(ability).count.should == 3
    end
  end

  describe "council" do
    let(:user){create(:user,role: 'council')}
    it "should NOT be able to manage all" do
      ability.can?(:manage,:all).should be_false
    end
    it "should be able to read all federations" do
      ability.can?(:read,Federation).should be_true
    end
    it "should be able to read all schools" do
      ability.can?(:read,School).should be_true
    end
    it "should be able to read all monthly values" do
      ability.can?(:read,MonthlyStat).should be_true
    end
  end

  describe "president" do
    let(:user){create(:user, role: 'president')}
    it "should NOT be able to manage all" do
      ability.can?(:manage,:all).should be_false
    end
    context "in a federation" do
      let(:fed){create(:federation)}
      before do
        user.update_attribute(:federation_id, fed.id)
      end
      it "should be able to read his federation" do
        ability.can?(:read,fed).should be_true
      end
      it "should NOT be able to read other federation" do
        ability.can?(:read,create(:federation)).should be_false
      end
      it "should be able to read schools from his federation" do
        create(:school)
        3.times{create(:school, federation: fed)}
        School.accessible_by(ability).count.should == 3
        ability.can?(:read,School.last).should be_true
      end
      it "should NOT be able to read OTHER federation stats" do
        ms = create(:monthly_stat, school: create(:school, federation: create(:federation)))
        ability.can?(:read,ms).should be_false
      end
      it "should be able to read HIS federation stats" do
        ms = create(:monthly_stat, school: create(:school, federation: fed))
        ability.can?(:read,ms).should be_true
      end
    end
  end

  describe "without role" do
    let(:user){create(:user)}
    it "should NOT be able to manage all" do
      ability.can?(:manage,:all).should be_false
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
          ability.can?(:read,fed).should be_false
        end
        it "should NOT be able to read other federation" do
          ability.can?(:read,create(:federation)).should be_false
        end
        it "should NOT be able to read schools from his federation" do
          create(:school)
          3.times{create(:school, federation: fed)}
          ability.can?(:read,School.last).should be_false
        end
        it "should NOT be able to read OTHER federation stats" do
          ms = create(:monthly_stat, school: create(:school, federation: create(:federation)))
          ability.can?(:read,ms).should be_false
        end
        it "should NOT be able to read HIS federation stats" do
          ms = create(:monthly_stat, school: create(:school, federation: fed))
          ability.can?(:read,ms).should be_false
        end
      end
    end
    context "with padma_accounts" do
      before do
        user.stub!(:enabled_accounts).and_return([PadmaAccount.new(name: 'this-account')])
      end
      context "in a federation" do
        let(:fed){create(:federation)}
        before do
          user.update_attribute(:federation_id, fed.id)
        end
        it "should not be able to read his federation" do
          ability.can?(:read,fed).should be_false
        end
        it "should NOT be able to read other federation" do
          ability.can?(:read,create(:federation)).should be_false
        end
        it "should NOT be able to read schools from his federation" do
          create(:school)
          3.times{create(:school, federation: fed)}
          ability.can?(:read,School.last).should be_false
          School.accessible_by(ability).count.should == 0
        end
        it "should be able to read his school" do
          s = create(:school, account_name: 'this-account')
          ability.can?(:read, s).should be_true
          School.accessible_by(ability).count.should == 1
        end
        it "should NOT be able to read OTHER federation stats" do
          ms = create(:monthly_stat, school: create(:school, federation: create(:federation)))
          ability.can?(:read,ms).should be_false
        end
        it "should NOT be able to read HIS federation stats" do
          ms = create(:monthly_stat, school: create(:school, federation: fed))
          ability.can?(:read,ms).should be_false
        end
      end
    end
  end
end

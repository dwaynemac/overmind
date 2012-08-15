require 'spec_helper'

describe Ability do
  describe "admin" do
    let(:user){create(:user,role: 'admin')}
    let(:ability){Ability.new(user)}
    it "should be able to manage all" do
      ability.can?(:manage,:all).should be_true
    end
  end

  describe "council" do
    let(:user){create(:user,role: 'council')}
    let(:ability){Ability.new(user)}
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

  describe "without role" do
    let(:user){create(:user)}
    let(:ability){Ability.new(user)}
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
end
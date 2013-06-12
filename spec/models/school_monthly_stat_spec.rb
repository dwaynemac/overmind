require 'spec_helper'

describe SchoolMonthlyStat do

  before do
    if SchoolMonthlyStat.count == 0
      create(:school_monthly_stat)
    end
  end

  it "checks that teacher_id is nil" do
    smt = build(:school_monthly_stat, teacher_id: 123)
    smt.should_not be_valid
    smt.errors[:teacher_id].should_not be_blank
  end

  it "should allow only one value per name per school per month" do
    should validate_uniqueness_of(:name).scoped_to([:ref_date,:school_id])

    prev = create(:monthly_stat, ref_date: Date.civil(2013,5,1))
    dup = build(:monthly_stat, school_id: prev.school_id, name: prev.name, value: 34, ref_date: Date.civil(2013,5,2))
    dup.should_not be_valid
  end

  describe ".sync_from_service!" do
    context "if stat exists" do
      let(:sms){create(:school_monthly_stat)}
      it "calls update_from_service! on it" do
        sms
        expect{SchoolMonthlyStat.sync_from_service!(sms.school,sms.name,sms.ref_date)}.not_to change{MonthlyStat.count}
      end
    end
    context "if stats doesnt exist" do
      it "calls create_from_service" do
        SchoolMonthlyStat.should_receive('create_from_service!')
        SchoolMonthlyStat.sync_from_service!(create(:school),'students',Date.today)
      end
    end
  end

  describe ".create_from_service!" do
    let(:school){ create(:school) }
    context "with name: students" do
      context "for kshema schools" do
        before do
          School.any_instance.stub(:fetch_stat).and_return('2')
        end
        it "creates a monthly stat On school" do
          expect{SchoolMonthlyStat.create_from_service!(school,:students,Date.today)}.to change{school.monthly_stats.count}.by(1)
        end
        it "uses KshemaAPi" do
          # stub for indexing.
          SchoolMonthlyStat.create_from_service!(school,:students,Date.today)
        end
      end
      context "for padma2 schools" do
        before do
          school.update_attribute :migrated_kshema_to_padma_at, Time.now
          School.any_instance.stub(:count_students).and_return '2'
        end
        it "created a monthly stat On school" do
          expect{SchoolMonthlyStat.create_from_service!(school,:students,Date.today)}.to change{school.monthly_stats.count}.by(1)
        end
        it "uses PADMA Modules APi" do
          # for indexing
          SchoolMonthlyStat.create_from_service!(school,:students,Date.today)
        end
      end
    end
  end

  describe "#update_from_service" do
    context "for monthly stat with service name kshema" do
      let(:ms){ create(:school_monthly_stat, value: 1, service: 'kshema')}
      before do
        School.any_instance.stub(:fetch_stat).and_return('4')
      end
      it "should update value" do
        ms.update_from_service!
        ms.reload.value.should == 4
      end
    end
    context "for monthly stat with service name crm" do
      let(:ms){ create(:school_monthly_stat, value: 1, service: 'crm', name: 'students')}
      before do
        School.any_instance.stub(:count_students).and_return('4')
      end
      it "should update value" do
        ms.update_from_service!
        ms.reload.value.should == 4
      end
    end
    context "for monthly stat without service name stored" do
      let(:ms){ create(:school_monthly_stat, value: 1)}
      before do
        School.any_instance.stub(:fetch_stat).and_return('4')
      end
      it "should not update value" do
        ms.update_from_service!
        ms.reload.value.should == 1
      end
    end
  end
  
end

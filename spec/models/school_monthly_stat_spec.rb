require 'rails_helper'

describe SchoolMonthlyStat do

  before do
    if SchoolMonthlyStat.count == 0
      create(:school_monthly_stat)
    end
  end

  it "checks that teacher_id is nil" do
    smt = build(:school_monthly_stat, teacher_id: 123)
    expect(smt).to_not be_valid
    expect(smt.errors[:teacher_id]).to_not be_blank
  end

  it "should allow only one value per name per school per month" do
    should validate_uniqueness_of(:name).scoped_to([:ref_date,:school_id])

    prev = create(:monthly_stat, ref_date: Date.civil(2013,5,1))
    dup = build(:monthly_stat, school_id: prev.school_id, name: prev.name, value: 34, ref_date: Date.civil(2013,5,2))
    expect(dup).to_not be_valid
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
        expect(SchoolMonthlyStat).to receive('create_from_service!')
        SchoolMonthlyStat.sync_from_service!(create(:school),'students',Date.today)
      end
    end
  end

  describe ".create_from_service!" do
    let(:school){ create(:school) }
    context "with name: students" do
      context "for kshema schools" do
        before do
          allow(MonthlyStat).to receive(:service_for).and_return 'kshema'
          allow_any_instance_of(School).to receive(:fetch_stat).and_return('2')
        end
        it "creates a monthly stat On school" do
          allow_any_instance_of(School).to receive(:fetch_stat_from_crm).and_return('2')
          expect{SchoolMonthlyStat.create_from_service!(school,:students,Date.today)}.to change{school.monthly_stats.count}.by(1)
        end
        it "uses KshemaAPi" do
          # stub for indexing.
          SchoolMonthlyStat.create_from_service!(school,:students,Date.today)
        end
      end
      context "for padma2 schools" do
        before do
          allow(MonthlyStat).to receive(:service_for).and_return 'crm'
          allow(school).to receive(:account).and_return(PadmaAccount.new(migrated_to_padma_on: Date.today))
          allow_any_instance_of(School).to receive(:count_students).and_return '2'
        end
        it "created a monthly stat On school" do
          expect{SchoolMonthlyStat.create_from_service!(school,:students,Date.today)}.to change{school.monthly_stats.count}.by(1)
        end
        it "works with date in variable" do
          ref = Date.civil(2014,10,31)
          expect{SchoolMonthlyStat.create_from_service!(school,:students,ref)}.to change{school.monthly_stats.count}.by(1)
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
        allow_any_instance_of(School).to receive(:fetch_stat).and_return('4')
      end
      it "should update value" do
        ms.update_from_service!
        expect(ms.reload.value).to eq 4
      end
    end
    context "for monthly stat with service name crm" do
      let(:ms){ create(:school_monthly_stat, value: 1, service: 'crm', name: 'students')}
      before do
        allow_any_instance_of(School).to receive(:count_students).and_return('4')
      end
      it "should update value" do
        ms.update_from_service!
        expect(ms.reload.value).to eq 4
      end
    end
    context "for monthly stat without service name stored" do
      let(:ms){ create(:school_monthly_stat, value: 1)}
      before do
        allow_any_instance_of(School).to receive(:fetch_stat).and_return('4')
      end
      it "should not update value" do
        ms.update_from_service!
        expect(ms.reload.value).to eq 1
      end
    end
  end
  
end

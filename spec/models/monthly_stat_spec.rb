require 'rails_helper'

describe MonthlyStat do
  before do
    create(:monthly_stat)
  end

  it_behaves_like "a stats matrix"

  context "if teacher_id is not set" do
    it "defaults type to SchoolMonthlyStat" do
      ms = build(:monthly_stat, teacher_id: nil)
      ms.save

      expect(ms.reload.type).to eq 'SchoolMonthlyStat'
      expect(SchoolMonthlyStat.last.id).to eq ms.id
    end
  end

  it "should ensure ref_date is end of month date" do
    ms = create(:monthly_stat, ref_date: Date.civil(2012,7,1))
    ms.save
    expect(ms.ref_date).to eq Date.civil(2012,7,31)
  end
  it "should belong to a school" do
    should belong_to :school
  end
  it "should always have a value" do
    should validate_presence_of :value
  end
  it "should always have a ref_date" do
    should validate_presence_of :ref_date
  end
  it "should always have a school" do
    should validate_presence_of :school
  end
  #it { should validate_inclusion_of(:name).in_array(MonthlyStat::VALID_NAMES)}

  it "stores service name" do
    should have_db_column :service
  end

  describe ".service_for" do
    describe "for a school without account_name" do
      let(:school){create(:school, account_name: nil)}
      it "returns ''" do
        expect(MonthlyStat.service_for(school,'students',Date.today)).to eq ''
      end
    end
    describe "for a school with account_name" do
      let(:school){create(:school, account_name: 'account-name')}
      describe "if communication with accounts-ws fails" do
        before do
          allow(school).to receive(:account).and_return nil
        end
        it "returns nil" do
          expect(MonthlyStat.service_for(school,'students',Date.today)).to be_nil
        end
      end
      describe "if school was not migrated to padma" do
        before do
          # stub_account(migrated_to_padma_on: nil)
          allow(school).to receive(:account).and_return  PadmaAccount.new({
            migrated_to_padma_on: nil,
            name: 'account-name'
          })
        end
        it "returns kshema" do
          expect(MonthlyStat.service_for(school,'students',Date.today)).to eq 'kshema'
        end
      end
      describe "if school was migrated to padma" do
        before do
          stub_account(migrated_to_padma_on: Date.civil(2013,1,1))
        end
        describe "if stat's ref_date is before migration date" do
          let(:ref_date){Date.civil(2012,1,1)}
          it "returns kshema" do
            expect(MonthlyStat.service_for(school,'students',ref_date)).to eq 'kshema'
          end
        end
        describe "if stat's ref_date is after migration date" do
          let(:ref_date){Date.civil(2014,1,1)}
          it "returns crm" do
            expect(MonthlyStat.service_for(school,'students',ref_date)).to eq 'crm'
          end
        end
      end
    end
  end
end

def stub_account(attrs)
  attrs = attrs.merge(name: 'account-name')
  allow(PadmaAccount).to receive(:find).with('account-name').and_return(
    PadmaAccount.new(attrs)
  )
end

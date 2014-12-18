require 'spec_helper'

describe "dropout rate" do
  let(:school){create(:school)}
  let(:ref_date){Date.today.end_of_month}
  let(:local_stat){LocalStat.new(school: school, ref_date: ref_date, name: :dropout_rate)}

  describe "if school has no students stat on prev month" do
    it "returns nil" do
      expect(local_stat.value).to be_nil
    end
  end

  describe "if school has 0 students on prev month" do
    let!(:interviews){create(:monthly_stat,
                             school: school,
                             ref_date: (ref_date-1.month).end_of_month,
                             name: :students,
                             value: 0
                            )}
    it "return nil" do
      expect(local_stat.value).to be_nil
    end
  end

  describe "if school has students on prev month" do
    let!(:interviews){create(:monthly_stat,
                             school: school,
                             ref_date: (ref_date-1.month).end_of_month,
                             name: :students,
                             value: 10
                            )}
    describe "but no dropouts stat" do
      it "returns nil" do
        expect(local_stat.value).to be_nil
      end
    end
    describe "but 0 dropouts" do
      let!(:dropouts){create(:monthly_stat,
                               school: school,
                               ref_date: ref_date,
                               name: :dropouts,
                               value: 0
                              )}
      it "returns 0" do
        expect(local_stat.value).to eq 0
      end
    end
    describe "and dropouts" do
      let!(:dropouts){create(:monthly_stat,
                               school: school,
                               ref_date: ref_date,
                               name: :dropouts,
                               value: 1
                              )}
      it "returns dropouts/students % as an integer" do
        expect(local_stat.value).to eq 10
      end
    end
  end

end

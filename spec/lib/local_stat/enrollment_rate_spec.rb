require 'rails_helper'

describe "enrollment rate" do
  let(:school){create(:school)}
  let(:ref_date){Date.today.end_of_month}
  let(:local_stat){LocalStat.new(school: school, ref_date: ref_date, name: :enrollment_rate)}

  describe "if school has no p_interviews stat" do
    it "returns nil" do
      expect(local_stat.value).to be_nil
    end
  end

  describe "if school has 0 p_interviews" do
    let!(:interviews){create(:monthly_stat,
                             school: school,
                             ref_date: ref_date,
                             name: :p_interviews,
                             value: 0
                            )}
    it "return nil" do
      expect(local_stat.value).to be_nil
    end
  end

  describe "if school has p_interviews" do
    let!(:interviews){create(:monthly_stat,
                             school: school,
                             ref_date: ref_date,
                             name: :p_interviews,
                             value: 10
                            )}
    describe "but no enrollments stat" do
      it "returns nil" do
        expect(local_stat.value).to be_nil
      end
    end
    describe "but 0 enrollments" do
      let!(:enrollments){create(:monthly_stat,
                               school: school,
                               ref_date: ref_date,
                               name: :enrollments,
                               value: 0
                              )}
      it "returns 0" do
        expect(local_stat.value).to eq 0
      end
    end
    describe "and enrollments" do
      describe "if enrollmets < interviews" do
        let!(:enrollments){create(:monthly_stat,
                                 school: school,
                                 ref_date: ref_date,
                                 name: :enrollments,
                                 value: 1
                                )}
        it "returns enrollments/interviews % as an integer (cents)" do
          expect(local_stat.value).to eq 1000
        end
      end
      describe "if enrollments > interviews" do
        let!(:enrollments){create(:monthly_stat,
                                 school: school,
                                 ref_date: ref_date,
                                 name: :enrollments,
                                 value: 11
                                )}
        it "returns nil" do
          expect(local_stat.value).to be_nil
        end
      end
    end
  end

end

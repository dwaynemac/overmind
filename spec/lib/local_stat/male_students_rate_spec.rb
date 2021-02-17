require 'rails_helper'

describe "male students rate" do
  let(:school){create(:school)}
  let(:ref_date){Date.today.end_of_month}
  let(:local_stat){LocalStat.new(school: school, ref_date: ref_date, name: :male_students_rate)}

  subject { local_stat.value }

  describe "when school has no students stat" do
    it { should be_nil }
  end

  describe "when school has 0 students" do
    let!(:students){create(:monthly_stat,
                           school: school,
                           ref_date: ref_date,
                           name: :students,
                           value: 0
                          )}
    it { should be_nil }
  end

  describe "when school has students" do
    let!(:students){create(:monthly_stat,
                           school: school,
                           ref_date: ref_date,
                           name: :students,
                           value: 10
                          )}
    describe "and no male students stat" do
      it { should be_nil }
    end
    describe "and 0 male students" do
      let!(:male_students){create(:monthly_stat,
                           school: school,
                           ref_date: ref_date,
                           name: :male_students,
                           value: 0
                          )}
      it { should eq 0 }
    end
    describe "and male students" do
      let!(:male_students){create(:monthly_stat,
                           school: school,
                           ref_date: ref_date,
                           name: :male_students,
                           value: 1
                          )}
      it "returns male / total % as integer (cents)" do
        should eq 1000
      end
    end
  end

end

require 'spec_helper'


describe "begginers dropout rate" do
  let(:school){create(:school)}
  let(:ref_date){Date.today.end_of_month}
  let(:local_stat){LocalStat.new(school: school, ref_date: ref_date, name: :begginers_dropout_rate)}

  describe "if schools has stat 'aspirante_students' for current month" do
    describe "of value: 0" do
      before {create(:monthly_stat, school: school, ref_date: ref_date, name: :aspirante_sudents, value: 0)}
      it { local_stat.value.should be_nil }
    end
    describe "of value: 1" do
      before {create(:monthly_stat, school: school, ref_date: ref_date, name: :aspirante_students, value: 1)}

      describe "and dropouts_begginers for chosen month" do
        before {create(:monthly_stat, school: school, ref_date: ref_date, name: :dropouts_begginers, value: 1)}

        it  { local_stat.value.should == 5000 }

        describe SchoolMonthlyStat do
          it "uses LocalStat for :begginers_dropout_rate" do
            ms = SchoolMonthlyStat.create_from_service!(school,:begginers_dropout_rate,ref_date)
            ms.value.should == 5000
          end
        end
      end

      describe "without dropouts_begginers for chosen month" do
        it "returns nil" do
          local_stat.value.should be_nil
        end
      end
    end
  end

  describe "if school has no 'aspirante_students' for previous month" do
    describe "but has dropouts_begginers for chosen month" do
      before {create(:monthly_stat, school: school, ref_date: ref_date, name: :aspirante_students, value: 2)}
      it { local_stat.value.should be_nil }
    end
    describe "and no dropouts_begginer for chosen month" do
      it { local_stat.value.should be_nil }
    end
  end
end

require 'spec_helper'


describe LocalStat do
  describe "calculates swasthya dropout rate" do
    let(:school){create(:school)}
    let(:ref_date){Date.today.end_of_month}
    let(:local_stat){LocalStat.new(school: school, ref_date: ref_date, name: :swasthya_dropout_rate)}

    describe "5 dropouts from swasthya" do
      before {create(:monthly_stat, school: school, ref_date: ref_date, name: :dropouts_intermediates, value: 5)}

      describe "10 aspirantes, 3 sadhakas, 2 yogins, 5 chelas last month" do
        before do
          create(:monthly_stat, school: school, ref_date: ref_date-1.month, name: :aspirante_students, value: 10)
          create(:monthly_stat, school: school, ref_date: ref_date-1.month, name: :sadhaka_students, value: 3)
          create(:monthly_stat, school: school, ref_date: ref_date-1.month, name: :yogin_students, value: 2)
          create(:monthly_stat, school: school, ref_date: ref_date-1.month, name: :chela_students, value: 5)
        end

        it { local_stat.value.should == 50 }
      end
    end
  end
end

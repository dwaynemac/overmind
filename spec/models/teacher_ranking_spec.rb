require 'rails_helper'

describe TeacherRanking do

  describe "initialization" do
    context "ref_since" do
      it "sets ref_since" do
        expect(TeacherRanking.new(ref_since: Date.today).ref_since).to eq Date.today
      end
    end
    context "ref_sice(1i) ref_since(2i)" do
      it "sets ref_since" do
        r = TeacherRanking.new(
          'ref_since(1i)' => 2014,
          'ref_since(2i)' => 10
        )
        expect(r.ref_since).to eq Date.civil(2014,10,1).end_of_month
      end
    end
  end

  describe "#stats" do
    let(:federation){create(:federation)}
    let(:school){create(:school, federation_id: federation.id)}
    let(:teacher){create(:teacher)}
    let(:teacher2){create(:teacher)}
    let(:ranking){TeacherRanking.new(ref_since: 3.months.ago,
                              ref_until: Date.today,
                              column_names: %W(enrollments_count),
                              federation_ids: [federation.id],
                              school_ids: [school.id])}
    before do
      create(:teacher_monthly_stat, ref_date: 1.month.ago, school: school, teacher: teacher)
      create(:teacher_monthly_stat, ref_date: 2.month.ago, school: school, teacher: teacher)
      create(:teacher_monthly_stat, ref_date: 4.month.ago, school: school, teacher: teacher)
   end
   it "gets stats between ref_since and ref_until" do
      expect(ranking.stats.count).to eq 1
   end
   it "reduces stats by teacher" do
      create(:teacher_monthly_stat, ref_date: 2.month.ago, school: school, teacher: teacher2)
      expect(ranking.stats.count).to eq 2
   end
   it "reduces stats by name" do
      create(:teacher_monthly_stat,
             name: 'other_stat',
             ref_date: 2.months.ago,
             school: school,
             teacher: teacher)
      ranking.column_names = %W(enrollments_count other_stat)
      expect(ranking.stats.size).to eq 2
   end
  end

  it "validates that ref_since < ref_until" do
    r = TeacherRanking.new ref_since: Date.today, ref_until: 2.months.ago
    expect(r.errors.keys).to eq []
  end
end

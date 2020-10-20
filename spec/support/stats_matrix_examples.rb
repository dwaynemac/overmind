shared_examples_for "a stats matrix" do
  describe "to_matrix" do
    let(:s){ create :school }
    before do
      @out_of_scope = create(:monthly_stat, school: create(:school), ref_date: Date.civil(2012,1,3), value: 3, name: 'enrollments')

      @apr = create(:school_monthly_stat, school: s, ref_date: Date.civil(2012,4,1), value: 1, name: 'enrollments')
      @dec = create(:school_monthly_stat, school: s, ref_date: Date.civil(2012,12,5),value: 6, name: 'enrollments')
      @jan = create(:school_monthly_stat, school: s, ref_date: Date.civil(2012,1,1), value: 4, name: 'enrollments')

      @matrix = Matrixer.new(s.monthly_stats).to_matrix
    end
    it "should default matrix[stat-name] to {}" do
      expect(@matrix.default).to eq({})
    end
    it "should default matrix[stat-name][month] to nil" do
      expect(@matrix[:'no-key'].default).to be_nil
      expect(@matrix[:enrollments].default).to be_nil
    end
    it "should store found stats on matrix keeping scope" do
      expect(@matrix[:enrollments][1]).to eq @jan
      expect(@matrix[:enrollments][4]).to eq @apr
      expect(@matrix[:enrollments][12]).to eq @dec
      expect(@matrix[:dropout_rate]).to eq({})
      expect(@matrix[:enrollment_rate]).to eq({})
    end
    context "when there is more than one stat in a month (eg: scoping by fed)" do
      before do
        @matrix = Matrixer.new(MonthlyStat.all).to_matrix
      end
      it "should set a ReducedStat" do
        expect(@matrix[:enrollments][1]).to be_a(ReducedStat)
      end
      it "should store SUM in #value" do
        expect(@matrix[:enrollments][1].value).to eq 7
      end
    end
    describe "dropout_rate" do
      before do
        @stud_jan = create(:monthly_stat, school: s, ref_date: Date.civil(2012,1,3), value: 3, name: 'students')
        @drop_jan = create(:monthly_stat, school: s, ref_date: Date.civil(2012,1,3), value: 1, name: 'dropouts')

        @stud_dec = create(:monthly_stat, school: s, ref_date: Date.civil(2012,12,3), value: 1, name: 'students')
        @drop_dec = create(:monthly_stat, school: s, ref_date: Date.civil(2012,12,3), value: 1, name: 'dropouts')

        SchoolMonthlyStat.create_from_service!(s,:dropout_rate,Date.civil(2012,1,3))
        SchoolMonthlyStat.create_from_service!(s,:dropout_rate,Date.civil(2012,12,3))

        @matrix = Matrixer.new(s.monthly_stats.for_year(2012)).to_matrix
      end
      it "should set matrix[:dropout_rate][1] to januaries dropout rate (cents)" do
        expect(@matrix[:dropout_rate][1].value).to eq 2500
      end
      it "should set matrix[:dropout_rate][12] to december dropout rate (cents)" do
        expect(@matrix[:dropout_rate][12].value).to eq 5000
      end
    end
    describe "enrollment_rate" do
      before do
        create(:monthly_stat, school: s, ref_date: Date.civil(2012,4,2), value: 2, name: 'p_interviews')
        create(:monthly_stat, school: s, ref_date: Date.civil(2012,1,2), value: 16, name: 'interviews')
        create(:monthly_stat, school: s, ref_date: Date.civil(2012,1,2), value: 8, name: 'p_interviews')
        SchoolMonthlyStat.create_from_service!(s,:enrollment_rate,Date.civil(2012,4,2))
        SchoolMonthlyStat.create_from_service!(s,:enrollment_rate,Date.civil(2012,1,2))

        @matrix = Matrixer.new(s.monthly_stats.all).to_matrix
      end
      it "should cosider P interviews, not total" do
        expect(@matrix[:enrollment_rate][1].value).to_not eq 2500
        expect(@matrix[:enrollment_rate][1].value).to eq 5000
      end
      it "should set matrix[:enrollment_rate][4] to april enrollment rate (cents)" do
        expect(@matrix[:enrollment_rate][4].value).to eq 5000
      end
    end
    it "shouldnt raise expection when scoped to federation" do
      expect{Matrixer.new(create(:federation).school_monthly_stats).to_matrix}.not_to raise_exception
    end
    describe "swasthya_students_subtotal" do
      before do
        create(:monthly_stat, school: s, ref_date: Date.civil(2012,1,1), value: 1, name: 'sadhaka_students')
        create(:monthly_stat, school: s, ref_date: Date.civil(2012,1,1), value: 1, name: 'yogin_students')
        create(:monthly_stat, school: s, ref_date: Date.civil(2012,1,1), value: 1, name: 'chela_students')

        @matrix = Matrixer.new(s.monthly_stats.all).to_matrix
      end
      it "should set matrix[:swasthya_students_subtotal][1] to 3" do
        expect(@matrix[:swasthya_students_subtotal][1].value).to eq 3
      end
      it 'should leave value nil if there are no stats in such month' do
        expect(@matrix[:swasthya_students_subtotal][2]).to be_nil
      end
    end
  end
end

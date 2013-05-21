shared_examples_for "it includes StatsMatrix" do
  describe "to_matrix" do
    let(:s){ create :school }
    before do
      @out_of_scope = create(:monthly_stat, school: create(:school), ref_date: Date.civil(2012,1,3), value: 3, name: 'enrollments')

      @apr = create(:school_monthly_stat, school: s, ref_date: Date.civil(2012,4,1), value: 1, name: 'enrollments')
      @dec = create(:school_monthly_stat, school: s, ref_date: Date.civil(2012,12,5),value: 6, name: 'enrollments')
      @jan = create(:school_monthly_stat, school: s, ref_date: Date.civil(2012,1,1), value: 4, name: 'enrollments')

      @matrix = s.monthly_stats.to_matrix
    end
    it "should default matrix[stat-name] to {}" do
      @matrix.default.should == {}
    end
    it "should default matrix[stat-name][month] to nil" do
      @matrix[:'no-key'].default.should be_nil
      @matrix[:enrollments].default.should be_nil
    end
    it "should store found stats on matrix keeping scope" do
      @matrix[:enrollments][1].should == @jan
      @matrix[:enrollments][4].should == @apr
      @matrix[:enrollments][12].should == @dec
      @matrix[:dropout_rate].should == {}
      @matrix[:enrollment_rate].should == {}
    end
    context "when there is more than one stat in a month (eg: scoping by fed)" do
      before do
        @matrix = MonthlyStat.to_matrix
      end
      it "should set a ReducedStat" do
        @matrix[:enrollments][1].should be_a(ReducedStat)
      end
      it "should store SUM in #value" do
        @matrix[:enrollments][1].value.should == 7
      end
    end
    describe "dropout_rate" do
      before do
        @stud_dec = create(:monthly_stat, school: s, ref_date: Date.civil(2011,12,3), value: 4, name: 'students')
        @drop_jan = create(:monthly_stat, school: s, ref_date: Date.civil(2012,1,3), value: 1, name: 'dropouts')

        @stud_nov = create(:monthly_stat, school: s, ref_date: Date.civil(2012,11,3), value: 2, name: 'students')
        @drop_dec = create(:monthly_stat, school: s, ref_date: Date.civil(2012,12,3), value: 1, name: 'dropouts')

        @matrix = s.monthly_stats.for_year(2012).to_matrix
      end
      it "should set matrix[:dropout_rate][1] to januaries dropout rate" do
        @matrix[:dropout_rate][1].value.should == 0.25
      end
      it "should set matrix[:dropout_rate][12] to december dropout rate" do
        @matrix[:dropout_rate][12].value.should == 0.5
      end
    end
    describe "enrollment_rate" do
      before do
        create(:monthly_stat, school: s, ref_date: Date.civil(2012,4,2), value: 2, name: 'p_interviews')
        create(:monthly_stat, school: s, ref_date: Date.civil(2012,1,2), value: 16, name: 'interviews')
        create(:monthly_stat, school: s, ref_date: Date.civil(2012,1,2), value: 8, name: 'p_interviews')

        @matrix = s.monthly_stats.to_matrix
      end
      it "should cosider P interviews, not total" do
        @matrix[:enrollment_rate][1].value.should_not == 0.25
        @matrix[:enrollment_rate][1].value.should == 0.5
      end
      it "should set matrix[:enrollment_rate][4] to april enrollment rate" do
        @matrix[:enrollment_rate][4].value.should == 0.5
      end
    end
    it "shouldnt raise expection when scoped to federation" do
      expect{create(:federation).school_monthly_stats.to_matrix}.not_to raise_exception
    end
    describe "swasthya_students_subtotal" do
      before do
        create(:monthly_stat, school: s, ref_date: Date.civil(2012,1,1), value: 1, name: 'sadhaka_students')
        create(:monthly_stat, school: s, ref_date: Date.civil(2012,1,1), value: 1, name: 'yogin_students')
        create(:monthly_stat, school: s, ref_date: Date.civil(2012,1,1), value: 1, name: 'chela_students')

        @matrix = s.monthly_stats.to_matrix
      end
      it "should set matrix[:swasthya_students_subtotal][1] to 3" do
        @matrix[:swasthya_students_subtotal][1].value.should == 3
      end
      it 'should leave value nil if there are no stats in such month' do
        @matrix[:swasthya_students_subtotal][2].should be_nil
      end
    end
  end
end
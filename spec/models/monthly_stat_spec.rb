require 'spec_helper'

describe MonthlyStat do
  before do
    create(:monthly_stat)
  end

  context "if teacher_id is not set" do
    it "defaults type to SchoolMonthlyStat" do
      ms = build(:monthly_stat, teacher_id: nil)
      ms.save

      ms.reload.type.should == 'SchoolMonthlyStat'
      SchoolMonthlyStat.last.id.should == ms.id
    end
  end

  it "should ensure ref_date is end of month date" do
    ms = create(:monthly_stat, ref_date: Date.civil(2012,7,1))
    ms.save
    ms.ref_date.should == Date.civil(2012,7,31)
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
  it { should ensure_inclusion_of(:name).in_array(MonthlyStat::VALID_NAMES)}
  
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
      expect{create(:federation).monthly_stats.to_matrix}.not_to raise_exception
    end
  end

  it "stores service name" do
    should have_db_column :service
  end

  describe ".create_from_service!" do
    let(:school){ create(:school) }
    context "with name: students" do
      context "for kshema schools" do
        before do
          School.any_instance.stub(:fetch_stat).and_return('2')
        end
        it "creates a monthly stat On school" do
          expect{MonthlyStat.create_from_service!(school,:students,Date.today)}.to change{school.monthly_stats.count}.by(1)
        end
        it "uses KshemaAPi" do
          # stub for indexing.
          MonthlyStat.create_from_service!(school,:students,Date.today)
        end
      end
      context "for padma2 schools" do
        before do
          school.update_attribute :migrated_kshema_to_padma_at, Time.now
          School.any_instance.stub(:count_students).and_return '2'
        end
        it "created a monthly stat On school" do
          expect{MonthlyStat.create_from_service!(school,:students,Date.today)}.to change{school.monthly_stats.count}.by(1)
        end
        it "uses PADMA Modules APi" do
          # for indexing
          MonthlyStat.create_from_service!(school,:students,Date.today)
        end
      end
    end
  end

  describe "#update_from_service" do
    context "for monthly stat with service name kshema" do
      let(:ms){ create(:monthly_stat, value: 1, service: 'kshema')}
      before do
        School.any_instance.stub(:fetch_stat).and_return('4')
      end
      it "should update value" do
        ms.update_from_service!
        ms.reload.value.should == 4
      end
    end
    context "for monthly stat with service name crm" do
      let(:ms){ create(:monthly_stat, value: 1, service: 'crm', name: 'students')}
      before do
        School.any_instance.stub(:count_students).and_return('4')
      end
      it "should update value" do
        ms.update_from_service!
        ms.reload.value.should == 4
      end
    end
    context "for monthly stat without service name stored" do
      let(:ms){ create(:monthly_stat, value: 1)}
      before do
        School.any_instance.stub(:fetch_stat).and_return('4')
      end
      it "should not update value" do
        ms.update_from_service!
        ms.reload.value.should == 1
      end
    end
  end
end
shared_examples_for "it uses NucleoApi for schools" do
  it { should validate_uniqueness_of :nucleo_id}
  describe "Class" do
    subject{klass}
    it { should respond_to :load_from_sv }
    describe "#load_from_sv" do
      before do
        @school = create(:school, name: 'old_name', nucleo_id: 4)
        fed = create(:federation)
        klass.api.stub(:paginate).and_return([RemoteSchool.new(name: 'school_a', id: 1, federation_id: fed.nucleo_id),
                                              RemoteSchool.new(name: 'school_b', id: 2, federation_id: fed.nucleo_id),
                                              RemoteSchool.new(name: 'school_c', id: 3, federation_id: fed.nucleo_id),
                                              RemoteSchool.new(name: 'new_name', id: 4, federation_id: fed.nucleo_id)
                                             ])
        Federation.api.stub(:find).and_return(RemoteFederation.new(name: 'federation_a', id: fed.nucleo_id))
        Federation.stub(:load_from_sv)
      end
      it "should create local school" do
        expect{klass.load_from_sv}.to change{School.count}.by 3
      end
      it "should update school names" do
        klass.load_from_sv
        @school.reload.name.should == 'new_name'
      end
      context "for school that changed federation" do
        let(:fed){ create(:federation)}
        let(:new_fed){ create(:federation)}
        let(:school){ create(:school, federation_id: fed.id)}
        before do
          Federation.api.stub(:find).and_return(RemoteFederation.new(name: 'federation_a', id: new_fed.nucleo_id))
          Federation.stub(:load_from_sv)
          klass.api.stub(:paginate).and_return([RemoteSchool.new(name: 'x', id: school.nucleo_id, federation_id: new_fed.nucleo_id)])
        end
        it "should update federation" do
          klass.load_from_sv
          school.reload.federation_id.should == new_fed.id
        end
      end
    end

    it { should respond_to :api }
    describe "#api" do
      subject{klass.api}
      #it "should return RemoteSchool class" do
      #  subject.class.name.should == 'RemoteSchool'
      #end
    end
  end
  describe "An instance" do
    subject{object}
    before do
      RemoteSchool.stub(:find).and_return(RemoteSchool.new)
    end
    it { should respond_to :api }
    describe "#api" do
      subject{object.api}
      it { should be_a RemoteSchool }
    end
  end
end
=begin
shared_examples_for "it uses FederationApi" do
  it { should validate_uniqueness_of :nucleo_id }
  describe "Class" do
    subject{klass}
    it { should respond_to :load_from_sv }
    describe "#load_from_sv" do
      before do
        @federation = create(:federation, name: 'old_name', nucleo_id: 3)
        klass.api.stub(:paginate).and_return([RemoteFederation.new(name: 'federation_a', id: 1),
                                              RemoteFederation.new(name: 'federation_b', id: 2),
                                              RemoteFederation.new(name: 'new_name',     id: 3)
                                             ])
        Federation.api.stub(:find).and_return(RemoteFederation.new(name: 'federation_a', id: 1))
      end
      it "should create local federation" do
        expect{klass.load_from_sv}.to change{Federation.count}.by 2
      end
      it "should update federation names" do
        klass.load_from_sv
        @federation.reload.name.should == 'new_name'
      end
    end

    it { should respond_to :api }
  end
  describe "An instance" do
    subject{object}
    it { should respond_to :api }
  end
end
=end

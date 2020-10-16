require 'rails_helper'

describe TeacherRankingsController do
  let(:user){create(:user,role: 'admin')}
  before do
      allow(PadmaUser).to receive(:find).and_return PadmaUser.new username: user.username, current_account_name: 'test-acc'
      sign_in(user)
  end

  let!(:school){create(:school, account_name: 'myacc')}

  describe "GET /schools/:school_id/teacher_ranking" do
    before do
      get :show,
          school_id: school.id
    end
    it { should respond_with 200 }
  end
  describe "GET /schools/:account_name/teacher_ranking" do
    before do
      get :show,
          school_id: school.account_name
    end
    it { should respond_with 200 }
  end

  describe "PUT /schools/:school_id/teacher_ranking" do
    before do
      put :show,
          school_id: school.id
    end
    it { should respond_with 200 }
  end

end

require 'spec_helper'

describe Teacher do

  before do
    if Teacher.count == 0
      create(:teacher)
    end
  end

  it { should have_and_belong_to_many :schools }
  it { should have_many :monthly_stats }
  it { should validate_uniqueness_of :username }

end

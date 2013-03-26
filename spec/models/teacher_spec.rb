require 'spec_helper'

describe Teacher do

  it { should have_and_belong_to_many :schools }
  it { should have_many :monthly_stats }
  it { should validate_uniqueness_of :username }



end

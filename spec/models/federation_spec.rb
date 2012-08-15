require 'spec_helper'

describe Federation do
  before do
    create(:federation)
  end
  it { should validate_uniqueness_of :name }
  it { should validate_presence_of :name }
  it { should have_many :schools }
  it { should have_many :users}
end

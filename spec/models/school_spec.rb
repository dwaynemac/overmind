require 'spec_helper'

describe School do
  before do
    create(:school)
  end
  it { should belong_to :federation }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
  it { should have_many :monthly_stats }
end

require 'spec_helper'

describe User do
  before do
    create(:user)
  end
  it { should validate_uniqueness_of :username }
  it { should validate_presence_of :username }
  it { should belong_to :federation }

  it { should have_db_column :role }
end

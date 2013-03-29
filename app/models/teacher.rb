class Teacher < ActiveRecord::Base
  attr_accessible :full_name, :username

  has_and_belongs_to_many :schools

  has_many :monthly_stats

  validates_uniqueness_of :username
end
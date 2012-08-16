class Federation < ActiveRecord::Base
  attr_accessible :name
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :users
  has_many :schools
  has_many :monthly_stats, through: :schools
end

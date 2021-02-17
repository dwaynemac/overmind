class Federation < ActiveRecord::Base
  #attr_accessible :name, :nucleo_id
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :users
  has_many :schools

  has_many :school_monthly_stats, through: :schools

  include FederationApi

end

class User < ActiveRecord::Base

  devise :cas_authenticatable

  attr_accessible :username, :federation_id, :role

  validates_uniqueness_of :username
  validates_presence_of :username
  belongs_to :federation
end

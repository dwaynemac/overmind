class User < ActiveRecord::Base

  include Accounts::IsAUser

  devise :cas_authenticatable

  attr_accessible :username, :federation_id, :role, :locale

  validates_uniqueness_of :username
  validates_presence_of :username
  belongs_to :federation

  VALID_ROLES = %W(admin council president)

  LOCALES = %W(es en pt)
end

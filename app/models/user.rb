class User < ActiveRecord::Base

  include Accounts::IsAUser

  devise :cas_authenticatable

  attr_accessible :username, :federation_id, :role, :locale

  validates_uniqueness_of :username
  validates_presence_of :username
  belongs_to :federation

  VALID_ROLES = %W(admin council president data_entry)

  LOCALES = %W(es en pt)

  def account_name
    self.padma.try :current_account_name
  end

  def current_account
    PadmaAccount.find_with_rails_cache self.account_name
  end

  def account_name_changed?
    false
  end

  def account_name=(new_name)
    self.padma.current_account_name = new_name
  end
end

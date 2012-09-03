class School < ActiveRecord::Base
  attr_accessible :name, :federation_id
  belongs_to :federation
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :monthly_stats

  def self.api
    RemoteSchool
  end

  def api
    self.nucleo_id.nil? ? nil : RemoteSchool.find(self.nucleo_id)
  end
end

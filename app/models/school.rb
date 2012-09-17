class School < ActiveRecord::Base
  attr_accessible :name, :federation_id, :nucleo_id
  belongs_to :federation
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :monthly_stats

  include SchoolApi

  def cache_last_student_count
    lsc = self.monthly_stats.where(name: :students).order(:ref_date).last
    self.update_attribute(:last_students_count, lsc.try(:value))
  end

end

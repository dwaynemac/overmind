class MonthlyStat < ActiveRecord::Base

  attr_accessible :value, :name, :school_id, :ref_date

  VALID_NAMES = [:enrollments, :dropouts, :students, :interviews]

  belongs_to :school
  validates_presence_of :school
  validates_presence_of :name
  validates_presence_of :ref_date
  validates_presence_of :value

  before_validation :move_ref_date_to_end_of_month
  validate :ref_date_is_end_of_month

  validates_uniqueness_of :name, scope: [:school_id, :ref_date]

  private

  def move_ref_date_to_end_of_month
    return if self.ref_date.nil?
    self.ref_date = self.ref_date.end_of_month
  end

  def ref_date_is_end_of_month
    return if self.ref_date.nil?
    if self.ref_date.end_of_month != ref_date
      errors.add(:ref_date, t('errors.attributes.ref_date.not_end_of_month'))
    end
  end
end

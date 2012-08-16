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

  def self.to_matrix
    matrix = Hash.new({})
    self.scoped.group_by(&:name).each_pair do |stat_name, stats|
      matrix[stat_name] = stats.group_by{|ms|ms.ref_date.month}
    end
    matrix.each_pair do |stat_name,stats_by_month|
      stats_by_month.each_pair do |month,stats|
        if stats.size>1
          matrix[stat_name][month] = ReducedStat.new(stats.sum(&:value))
        else
          matrix[stat_name][month] = stats.first
        end
      end
    end
  end

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

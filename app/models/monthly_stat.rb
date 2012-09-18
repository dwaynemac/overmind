class MonthlyStat < ActiveRecord::Base

  attr_accessible :value, :name, :school_id, :ref_date, :service

  VALID_NAMES = [:enrollments, :dropouts, :students, :interviews, :p_interviews]

  belongs_to :school
  validates_presence_of :school
  validates_presence_of :name
  validates_presence_of :ref_date
  validates_presence_of :value

  before_validation :cast_ref_date_to_date
  before_validation :move_ref_date_to_end_of_month
  validate :ref_date_is_end_of_month

  validates_uniqueness_of :name, scope: [:school_id, :ref_date]

  def self.for_month(ref_date)
    where(ref_date: ref_date.to_date.end_of_month)
  end

  def self.for_year(year)
    year = year.to_i
    where(ref_date: (Date.civil(year,1,1)..Date.civil(year,12,31)))
  end

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
    matrix.symbolize_keys!
  end

  def importing=(v)
    @importing = v
  end

  def importing?
    !!@importing
  end

  after_save :cache_student_count, unless: ->{self.importing?}

  def cache_student_count
    self.school.cache_last_student_count
  end

  # creates a new MonthlyStat
  # @example @school.monthly_stats.create_from_service!(:enrollments, Date.today)
  # @raise exception is creation fails
  # @return [MonthlyStat/NilClass]
  def self.create_from_service!(school,name,ref_date)
    # TODO identify schools service
    ms = school.monthly_stats.new(name: name, ref_date: ref_date, service: 'kshema')
    remote_value = school.fetch_stat(name, ref_date)
    if remote_value
      ms.value = remote_value
    end
    ms.save ? ms : nil
  end

  # updates value
  # @return [Integer] new value
  def update_from_service!
    # TODO identify schools service
    remote_value = self.school.fetch_stat(self.name,self.ref_date)
    if remote_value && remote_value != self.value
      self.update_attributes value: remote_value, service: 'kshema'
    else
      nil
    end
  end

  private

  def cast_ref_date_to_date
    unless self.ref_date.nil? || self.ref_date.is_a?(Date)
      self.ref_date = self.ref_date.to_date
    end
  end

  def move_ref_date_to_end_of_month
    return if self.ref_date.nil?
    self.ref_date = self.ref_date.to_date.end_of_month
  end

  def ref_date_is_end_of_month
    return if self.ref_date.nil?
    if self.ref_date.to_date.end_of_month != ref_date
      errors.add(:ref_date, t('errors.attributes.ref_date.not_end_of_month'))
    end
  end
end

class School < ActiveRecord::Base
  attr_accessible :name, :federation_id, :nucleo_id, :account_name
  belongs_to :federation
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :monthly_stats, dependent: :destroy

  include SchoolApi
  
  include BelongsToAccount
  validates_uniqueness_of :account_name, allow_blank: true

  include KshemaApi

  # @param year [Integer]
  # @param options [Hash]
  # @option options :update_existing (false)
  def sync_year_stats(year,options={})
    MonthlyStat::VALID_NAMES.each do |name|
      months_range = (year == Time.zone.today)? (1..Time.zone.today.month-1) : (1...13)
      months_range.each do |month|
        ref_date = Date.civil(year.to_i,month,1)
        stats_for_month = self.monthly_stats.where(name: name).for_month(ref_date)
        if stats_for_month.empty?
          MonthlyStat.create_from_service!(self,name,ref_date)
        else
          if options[:update_existing]
            stats_for_month.last.update_from_service!
          end
        end
      end
    end
    self.update_attribute(:synced_at,Time.now)
  end

  def cache_last_student_count
    lsc = self.monthly_stats.where(name: :students).order(:ref_date).last
    self.update_attribute(:last_students_count, lsc.try(:value))
  end

  def cache_last_teachers_count
    sum = 0
    [:assistant_students, :professor_students, :master_students].each do |stat_name|
      l = self.monthly_stats.where(name: stat_name).order(:ref_date).last
      if l
        sum += l.value
      end
    end
    self.update_attribute(:last_teachers_count, sum)
  end

  # @return nil on Connection Problems
  # @return [TrueClass]
  def nucleo_enabled?
    !!(self.api.try(:uni_status) == '1')
  end

  # @return nil on Connection Problems
  # @return [TrueClass]
  def padma_enabled?
    if self.account_name.present? && self.account.present?
      self.account.enabled?
    end
  end

end

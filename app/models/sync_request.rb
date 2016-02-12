##
# SyncRequest
#
# corresponds to a specific month-year and a specific school.
#
# @!attribute priority [rw]
#   @return [String] importance of this sync.
#                    nil or < 5 will only be synced at night
#                    syncs are excecuted in order of priority.
#                    scheduled syncs have low priority by default
#                    syncs requestes by user through web have high priority
#
class SyncRequest < ActiveRecord::Base
  attr_accessible :school_id, :year, :month, :state, :synced_at, :filter_by_event

  attr_accessible :priority

  belongs_to :school

  validates_presence_of :school_id
  validates_presence_of :year
  validates :month,
            presence: true,
            numericality: { greater_than: 0,
                            less_than: 13 }
  
  validate :valid_ref_date
  validate :only_one_unfinished_per_school_per_month

  before_validation :set_defaults

  # ready - sync not started
  # running - sync currently running
  # paused - sync in progress but paused
  # failed - sync stoped with an exception
  # finished - sync successfully finished
  STATES = %W(ready running paused failed finished)

  scope :in_progress, where(state: %W(paused running))
  scope :failed, where(state: 'failed')
  scope :pending, where(state: %W(ready paused))
  scope :unfinished, where(state: %W(ready paused running failed))
  scope :finished, where(state: 'finished')
  scope :prioritized, order('priority desc')
  scope :night_only, where("priority IS NULL OR priority < 5")
  scope :not_night_only, where("NOT (priority IS NULL OR priority < 5)")

  def self.on_ref_date(options={})
    scope = self.scoped
    if options[:year]
      scope = scope.where(year: options[:year])
    end
    if options[:month]
      scope = scope.where(month: options[:month])
    end
    scope
  end

  # @param safe [Boolean] if true, exceptions will be catched and logged without raising (true)
  # @return [String] state 
  def start(safe=true)
    return unless school.present? && year.present? && month.present?
    return if finished? || failed?

    update_attribute :state, 'running'

    if syncable_month?(month)
      sync_school_stats
      sync_teachers_stats
    end

    update_attributes(state: 'finished')

    state
  rescue => e
    Appsignal.send_exception(e)
    update_attribute :state, 'failed'
    if safe
      logger.warn "SyncRequest #{self.id} failed with exception."
      logger.debug e.message
      state
    else
      raise e
    end
  end

  def sync_school_stats
    ref = ref_date(year,month)
    school_stat_names.each do |name|
      SchoolMonthlyStat.sync_from_service!(school,name,ref)
    end
  end

  def sync_teachers_stats
    ref = ref_date(year,month)
    teacher_stat_names.each do |name|
      TeacherMonthlyStat.sync_school_from_service(school,name,ref)
    end
  end

  def ready?
    state == 'ready'
  end

  def paused?
    state == 'paused'
  end

  def pending?
    state.in?([nil, 'ready', 'paused', 'failed'])
  end

  def failed?
    state == 'failed'
  end

  def finished?
    state == 'finished'
  end

  # Return if this syncRequest should be run only at night.
  # @return [Boolean]
  def night_only?
    priority.nil? || priority < 5
  end

  def low_priority?
    priority < 10
  end

  private
  
  def valid_ref_date
    if year && month
      if ref_date(year,month).end_of_month > Time.zone.now.to_date.end_of_month
        self.errors.add(:month, 'can sync future months')
      end
    end
  end

  def only_one_unfinished_per_school_per_month
    return if self.persisted?
    if school && school.sync_requests.unfinished.where(year: year, month: month).count > 0
      self.errors.add(:base, 'already have a sync_request for this month for this school')
    end
  end

  # Checks if given month is not in the future
  # @param month [Integer] 
  # @return [Boolean]
  def syncable_month?(month)
    (self.year < Time.now.year && month <= 12) || (self.year == Time.now.year && month <= Time.now.month)
  end

  def set_defaults
    self.state = 'ready' if state.nil?
    self.month = 1 if month.nil?
    self.priority = 0 if priority.nil?
  end

  # @param year [Integer]
  # @param month [Integer]
  # @return Date
  def ref_date(year,month)
    Date.civil(year.to_i,month.to_i,1).end_of_month
  end

  def school_stat_names
    self.filter_by_event = self.filter_by_event.try(:to_s)
    if self.filter_by_event.blank? || SchoolMonthlyStat.stats_for_event(self.filter_by_event).nil?
      MonthlyStat::VALID_NAMES
    else
      SchoolMonthlyStat.stats_for_event(self.filter_by_event)
    end
  end

  def teacher_stat_names
    self.filter_by_event = self.filter_by_event.try(:to_s)
    if self.filter_by_event.blank? || TeacherMonthlyStat.stats_for_event(self.filter_by_event).nil?
      TeacherMonthlyStat::STATS_BY_TEACHER
    else
      TeacherMonthlyStat.stats_for_event(self.filter_by_event)
    end
  end
end

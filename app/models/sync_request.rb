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
  attr_accessible :school_id, :year, :month, :state, :synced_at

  attr_accessible :priority

  belongs_to :school

  validates_presence_of :school_id
  validates_presence_of :year
  validates :month,
            presence: true,
            numericality: { greater_than: 0,
                            less_than: 13 }
  
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

  # @param safe [Boolean] if true, exceptions will be catched and logged without raising (true)
  def start(safe=true)
    return unless school.present? && year.present? && month.present?
    return if finished? || failed?

    update_attribute :state, 'running'

    new_attributes = {}
    if syncable_month?(month)
      school.sync_school_month_stats(year,month,{update_existing: true, skip_synced_at_setting: true})
      school.sync_teacher_monthly_stats(year,month)
    end

    update_attributes(state: 'finished')

    state
  rescue => e
    update_attribute :state, 'failed'
    if safe
      logger.warn "SyncRequest #{self.id} failed with exception."
      logger.debug e.message
      state
    else
      raise e
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

  # @return [Integer] porcentage of progress
  def progress
    end_month = (self.year < Time.now.year)? 12 : Time.now.month
    (synced_upto*100/end_month).to_i
  end

  # Return if this syncRequest should be run only at night.
  # @return [Boolean]
  def night_only?
    priority.nil? || priority < 5
  end

  private

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
end

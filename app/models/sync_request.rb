class SyncRequest < ActiveRecord::Base
  attr_accessible :school_id, :year, :state, :synced_at

  attr_accessible :synced_upto # will save up to what month we have already synced this year.

  belongs_to :school

  validates_presence_of :school_id
  validates_presence_of :year
  validate :only_one_unfinished_per_school

  before_create :set_defaults

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

  # @param safe [Boolean] if true, exceptions will be catched and logged without raising (true)
  def start(safe=true)
    return unless school.present? && year.present?
    return if finished? || failed?

    sync_month = synced_upto+1
    if sync_month > 12
      # This should never happen, state should be :finished
      logger.debug 'SyncRequest #{self.id} is attempting to go over 12'
      return
    end

    self.update_attribute :state, 'running'

    new_attributes = {}
    if syncable_month?(sync_month)
      school.sync_teacher_monthly_stats(year,sync_month)
      school.sync_school_month_stats(year,sync_month,{update_existing: true, skip_synced_at_setting: true})

      # save progress and state
      new_attributes[:synced_upto] = sync_month
    end

    if last_syncable_month?(sync_month)
      new_attributes[:state] = 'finished'
      self.school.update_attribute(:synced_at,Time.now)
      self.school.cache_last_student_count
    else
      new_attributes[:state] = 'paused'
    end
    self.update_attributes(new_attributes)

    self.state
  rescue => e
    self.update_attribute :state, 'failed'
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

  private

  def only_one_unfinished_per_school
    return if self.persisted?
    if self.school && self.school.sync_requests.unfinished.count > 0
      self.errors.add(:base, 'already have a sync_request for this school')
    end
  end

  # Checks if given month is not in the future
  # @param month [Integer] 
  # @return [Boolean]
  def syncable_month?(month)
    (self.year < Time.now.year && month <= 12) || (self.year == Time.now.year && month <= Time.now.month)
  end

  # Checks if this is the last syncable month of self.year
  # @param month [Integer] 
  # @return [Boolean]
  def last_syncable_month?(month)
    (self.year < Time.now.year && month == 12) || (self.year == Time.now.year && month == Time.now.month)
  end

  def set_defaults
    self.state = 'ready' if state.nil?
    self.synced_upto = 0
  end
end

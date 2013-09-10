class SyncRequest < ActiveRecord::Base
  attr_accessible :school_id, :year, :state

  attr_accessible :synced_upto # will save up to what month we have already synced this year.

  belongs_to :school

  validates_presence_of :school_id
  validates_presence_of :year

  before_create :set_defaults

  # ready - sync not started
  # in_progress - sync currently running
  # paused - sync in progress but paused
  # failed - sync stoped with an exception
  # finished - sync successfully finished
  STATES = [:ready, :in_progress, :paused, :failed, :finished]

  scope :failed, where(state: 'failed')
  scope :pending, where(state: %W(ready paused failed))
  scope :finished, where(state: 'finished')

  def start(safe=true)
    return unless school.present? && year.present?
    self.update_attribute :state, 'in_progress'

    sync_month = synced_upto+1

    school.sync_teacher_monthly_stats(year,sync_month)
    school.sync_school_month_stats(year,sync_month,{update_existing: true, skip_synced_at_setting: true})

    # save progress and state
    new_attributes = {}
    new_attributes[:synced_upto] = sync_month

    if synced_upto == 12
      new_attributes[:state] = :finished
      new_attributes[:synced_at] = Time.now
    elsif synced_upto > 12
      raise 'SyncRequest #{self.id} is attempting to go over 12'
    else
      new_attributes[:state] = :paused
    end
    self.update_attributes(new_attributes)

    self.state
  rescue => e
    self.update_attribute :state, 'failed'
    unless safe
      raise e
    else
      logger.warn "SyncRequest #{self.id} failed with exception."
      logger.debug e.message
    end
    state
  end

  def pending?
    state.in?([nil, 'ready', 'paused', 'failed'])
  end

  def failed?
    state == 'failed'
  end

  def finshed?
    state == 'finished'
  end

  private

  def set_defaults
    self.state = 'ready' if state.nil?
    self.synced_upto = 0
  end
end

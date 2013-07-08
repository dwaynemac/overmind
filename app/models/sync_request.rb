class SyncRequest < ActiveRecord::Base
  attr_accessible :school_id, :year, :state

  belongs_to :school

  validates_presence_of :school_id
  validates_presence_of :year

  before_create :default_state

  scope :failed, where(state: 'failed')
  scope :pending, where(state: %W(ready failed))
  scope :finished, where(state: 'finished')

  def start
    return unless school.present? && year.present?

    self.update_attribute :state, 'in_progress'

    school.sync_year_stats(year, update_existing: true)

    self.update_attribute(:state, (school.synced_at > 10.minutes.ago)? 'finished' : 'failed')
    state
  rescue
    self.update_attribute :state, 'failed'
    state
  end

  def pending?
    state.in?([nil, 'ready', 'failed'])
  end

  def failed?
    state == 'failed'
  end

  def finshed?
    state == 'finished'
  end

  private

  def default_state
    self.state = 'ready' if state.nil?
  end
end

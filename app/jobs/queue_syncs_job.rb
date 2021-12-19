class QueueSyncsJob

  attr_accessor :stats_scope

  def initialize(stats_scope)
    self.stats_scope = stats_scope
  end

  def perform
    stats_scope.each{|sms| sms.queue_resync }
  end

  DEFAULT_PRIORITY = 0
  def queue_myself(queue_options = {})
    Delayed::Job.enqueue self, {priority: DEFAULT_PRIORITY}.reverse_merge(queue_options)
  end

end

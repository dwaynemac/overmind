class LocalStat

  def initialize(attributes={})
    @school   = attributes[:school]
    @name     = attributes[:name]
    @ref_date = attributes[:ref_date]
  end

  def value
    # modules that define calculations are included
    # from lib/local_stat/
    @value ||= send("calculate_#{@name}")
  end

  private

  def value_for(stat_name)
    ms = MonthlyStat.where(school_id: @school.id, ref_date: @ref_date, name: stat_name)
    ms.first.try(:value)
  end

  @@registered_stats = []
  def self.register_stat(stat_name)
    @@registered_stats << stat_name
  end

  def self.registered_stats
    @@registered_stats
  end

end

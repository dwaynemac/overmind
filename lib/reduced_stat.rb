# Used for Derived Stats
class ReducedStat

  # stats_scope shouldnt have condition on name. 
  attr_accessor :ref_date, :name,
                :school, :teacher,
                :stats, :stats_scope,
                :reduce_as, :unit
                

  def initialize(attributes)
    self.school = attributes[:school]
    self.teacher = attributes[:teacher]

    self.stats = attributes[:stats]
    self.stats_scope = attributes[:stats_scope]

    self.name = attributes[:name] || stats.try(:first).try(:name) || stats_scope.try(:first).try(:name) 
    self.ref_date = attributes[:ref_date] || data.try(:first).try(:ref_date)
    self.reduce_as = attributes[:reduce_as] || default_reduction

    self.unit = attributes[:unit] || stats.try(:first).try(:unit)

    @value = attributes[:value]
    self
  end

  def value 
    if @value
      @value
    else
      if LocalStat.has_special_reduction?(name)
        @value = LocalStat.new().send("reduce_#{name}", stats_scope )
      else
        @value = case self.reduce_as.to_sym
          when :sum
            compacted_stats.sum(&:value)
          when :avg
            compacted_stats.sum(&:value).to_f / self.size
        end
      end
    end
  end

  def compacted_stats
    if data
      @compacted_stats ||= data.reject{|s| s.value.nil? }
    end
  end

  def data
    @data ||= if stats
      stats
    elsif stats_scope
      stats_scope.where(name: name)
    end
  end

  def size
    @size ||= compacted_stats.try(:size) || 0
  end

  def school_id
    self.school.try(:id)
  end

  def teacher_id
    self.teacher.try(:id)
  end

  def service
    nil
  end

  def is_a_rate?
    MonthlyStat.is_a_rate?(self.name)
  end
  
  def default_reduction
    MonthlyStat.default_reduction(name) || :sum
  end
end

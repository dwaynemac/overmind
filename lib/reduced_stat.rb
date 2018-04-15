# Used for Derived Stats
class ReducedStat
  attr_accessor :ref_date, :name, :stats, :name, :reduce_as, :school, :teacher

  # TODO si agregamos el attribute :stats_scope podemos resolver aca adentro los casos de special_reduction   
  def initialize(attributes)
    self.school = attributes[:school]
    self.teacher = attributes[:teacher]
    self.stats = attributes[:stats]
    self.name = attributes[:name] || stats.try(:first).try(:name)
    self.ref_date = attributes[:ref_date] || stats.try(:first).try(:ref_date)
    self.reduce_as = attributes[:reduce_as] || default_reduction
    @value = attributes[:value]
    self
  end

  def value 
    if @value
      @value
    else
      if LocalStat.has_special_reduction?(name)
        # value should have been set on initialization
        # TODO with :stats_scope attribute we could calculate here
        @value 
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
    if stats
      @compacted_stats ||= stats.reject{|s| s.value.nil? }
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

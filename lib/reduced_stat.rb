# Used for Derived Stats
class ReducedStat
  attr_accessor :ref_date, :name, :stats, :name, :reduce_as, :school, :teacher

  def initialize(attributes)
    self.school = attributes[:school]
    self.teacher = attributes[:teacher]
    self.stats = attributes[:stats]
    self.name = attributes[:name] || stats.try(:first).try(:name)
    self.ref_date = attributes[:ref_date] || stats.try(:first).try(:ref_date)
    self.reduce_as = attributes[:reduce_as] || :sum
    @value = attributes[:value]
    self
  end

  def value 
    @value ||= case self.reduce_as.to_sym
      when :sum
        self.stats.sum(&:value)
      when :avg
        self.stats.sum(&:value).to_f / self.size
    end
  end

  def size
    @size ||= self.stats.try(:size) || 0
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
end

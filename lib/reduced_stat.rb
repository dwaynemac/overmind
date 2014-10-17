# Used for Derived Stats
class ReducedStat
  attr_accessor :ref_date, :name, :stats, :name, :reduce_as, :school

  def initialize(attributes)
    self.school = attributes[:school]
    self.stats = attributes[:stats]
    self.name = attributes[:name] || stats.try(:first).try(:name)
    self.ref_date = attributes[:ref_date] || stats.try(:first).try(:ref_date)
    self.reduce_as = attributes[:reduce_as] || :sum
    @value = attributes[:value]
  end

  def value 
    @value ||= case self.reduce_as.to_sym
      when :sum
        self.stats.sum(&:value)
      when :avg
        self.stats.sum(&:value).to_f / self.stats.size
    end
  end

  def service
    nil
  end
end

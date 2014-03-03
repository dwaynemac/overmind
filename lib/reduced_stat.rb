# Used for Derived Stats
class ReducedStat
  attr_accessor :value, :ref_date

  def initialize(attributes)
    self.value = attributes[:value]
    self.ref_date = attributes[:ref_date]
  end

  def service
    nil
  end
end

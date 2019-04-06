##
# LocalStat calculates locally. This class is the stat calculator.
# It is called from MonthlyStat when service is 'overmind'
#
# Calculation's are written in separate modules and included. All calculation
# methods must have a method "calculate_#{stat_name}" that returns stats value
#
# @school, @name and @ref_date are available for calculation.
#
# value_for(stat_name) is also available for calculations
#
# ADDIND NEW LOCAL STATS:
#   - add name to NAMES constant
#   - write module and include it here
#   - module show have method "calculate_{stat_name}" that returns stat value
class LocalStat

  NAMES = [
    :male_students_rate,
    :aspirante_students_rate,
    :sadhaka_students_rate,
    :yogin_students_rate,
    :chela_students_rate,
    :begginers_dropout_rate,
    :swasthya_dropout_rate,
    :enrollment_rate,
    :male_enrollment_rate,
    :dropout_rate,
    :male_demand_rate,
    :female_demand_rate,
    :male_interviews_rate,
    :female_interviews_rate
  ]
  
  DEPENDENCIES = {
    
  }
  
  include BegginersDropoutRate
  include SwasthyaDropoutRate
  include EnrollmentRate
  include MaleEnrollmentRate
  
  include DropoutRate
  include MaleStudentsRate

  include AspiranteStudentsRate
  include SadhakaStudentsRate
  include YoginStudentsRate
  include ChelaStudentsRate

  include MaleDemandRate
  include FemaleDemandRate
  include MaleInterviewsRate
  include FemaleInterviewsRate

  def initialize(attributes={})
    @school   = attributes[:school]
    @name     = attributes[:name]
    @ref_date = attributes[:ref_date]
    @ref_date = @ref_date.end_of_month if @ref_date
    @teacher = attributes[:teacher]
  end

  def value
    # modules that define calculations are included
    # from lib/local_stat/
    @value ||= send("calculate_#{@name}")
  end

  # True for all stats that are calculated locally, here, in overmind.
  # @return [Boolean]
  def self.is_local_stat?(stat_name)
    stat_name.to_sym.in?(registered_stats)
  end
  
  def self.has_special_reduction?(stat_name)
    self.new().respond_to?("reduce_#{stat_name}")
  end
  
  # scope, returns stat names that depend on given name
  # @return [Array<String>] 
  def self.dependant_on(name)
    registered_stats.map do |local_stat_name|
      mthd = "#{local_stat_name}_dependencies"
      if respond_to?(mthd) && name.to_sym.in?(send(mthd)) 
        local_stat_name
      end
    end.compact
  end

  private

  # @param stat_name
  # @param ref_date
  def value_for(stat_name, ref_date=nil)
    ref_date = @ref_date if ref_date.nil?
    ms = MonthlyStat.where(school_id: @school.id, ref_date: ref_date, name: stat_name, teacher_id: @teacher.try(:id))
    ms.first.try(:value)
  end

  def self.registered_stats
    # if we could register stats in a class variable constante wouldn't
    # be necessary
    NAMES
  end

end

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
  include BegginersDropoutRate
  include SwasthyaDropoutRate
  include EnrollmentRate
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

  def self.calculate_all(options={})

    dependency = {
      male_students_rate: :male_students,
      male_demand_rate: :male_demand,
      female_demand_rate: :female_demand,
      aspirante_students_rate: :aspirante_students,
      sadhaka_students_rate: :sadhaka_students,
      yogin_students_rate: :yogin_students,
      chela_students_rate: :chela_students,
      begginers_dropout_rate: :dropouts_begginers,
      swasthya_dropout_rate: :dropouts_intermediates,
      enrollment_rate: :enrollments,
      male_enrollment_rate: :male_enrollments,
      dropout_rate: :dropouts
    }

    NAMES.each do |local_stat_name|
      dependencies = SchoolMonthlyStat.where(name: dependency[local_stat_name])
      if options[:account_name]
        s = School.where(account_name: options[:account_name]).first
        dependencies = dependencies.where(school_id: s.id) if s
      end
      if options[:from]
        dependencies = dependencies.where("ref_date > ?", options[:from])
      end
      if options[:to]
        dependencies = dependencies.where("ref_date < ?", options[:to])
      end
      dependencies.each do |ms|
        Rails.logger.debug "calculating #{local_stat_name} for school #{ms.school_id} on #{ms.ref_date}"
        SchoolMonthlyStat.create_from_service!(ms.school, local_stat_name, ms.ref_date)
      end
      teacher_dependencies = TeacherMonthlyStat.where(name: dependency[local_stat_name])
      if options[:account_name]
        s = School.where(account_name: options[:account_name]).first
        teacher_dependencies = teacher_dependencies.where(school_id: s.id) if s
      end
      if options[:from]
        teacher_dependencies = teacher_dependencies.where("ref_date > ?", options[:from])
      end
      if options[:to]
        teacher_dependencies = teacher_dependencies.where("ref_date < ?", options[:to])
      end
      teacher_dependencies.each do |ms|
        Rails.logger.debug "calculating #{local_stat_name} for teacher #{ms.teacher_id} on #{ms.ref_date}"
        value = TeacherMonthlyStat.calculate_local_value(ms.school,ms.teacher,local_stat_name,ms.ref_date)
        TeacherMonthlyStat.create_or_update(ms.school,ms.teacher,local_stat_name,ms.ref_date,value) if value
      end
    end
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

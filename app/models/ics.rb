class Ics

  attr_reader :school

  ICS = [
    :demand,
    :conversion_rate,
    :p_interviews,
    :enrollments,
    :enrollment_rate,
    :dropout_rate,
    :students_average_age,
    :male_students,
    :students
  ]

  def initialize(school,ref_date)
    @school = school
    @ref_date = ref_date
  end

  def monthly_stats(name=nil)
    @monthly_stats ||= SchoolMonthlyStat.where(
      school_id: @school.id,
      name: ICS,
      ref_date: @ref_date.end_of_month
    )

    if name
      @monthly_stats.select{|ms| ms.name == name }.first
    else
      @monthly_stats
    end
  end

  def manual_input?
    !@school.padma_enabled?
  end
end

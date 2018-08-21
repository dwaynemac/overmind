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

  ICS.each do |ic|
    define_method(ic) do
      monthly_stats(ic).try(:value)
    end
  end

  def update_stats(attrs)
    attrs.keys.each do |ic|
      unless attrs[ic].blank?
        if monthly_stats(ic).nil?
          # create
          sms = SchoolMonthlyStat.new
          sms.school_id = @school.id
          sms.ref_date = @ref_date.end_of_month
          sms.name = ic
          sms.service = nil
          sms.value = attrs[ic]
          sms.save
        else
          # TODO check if service is local !!! 
          monthly_stats(ic).update_attribute :value, attrs[ic]
        end
      end
    end
  end

  def monthly_stats(name=nil)
    @monthly_stats ||= SchoolMonthlyStat.where(
      school_id: @school.id,
      name: ICS,
      ref_date: @ref_date.end_of_month
    )

    if name
      @monthly_stats.select{|ms| ms.name.to_s == name.to_s }.first
    else
      @monthly_stats
    end
  end

  def manual_input?
    !@school.padma_enabled?
  end

end

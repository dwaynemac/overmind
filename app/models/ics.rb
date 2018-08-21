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
      stat = monthly_stats(ic)
      if stat
        if stat.is_a_rate?
          # rates are represented as 'cents' in integer.
          stat.value.to_f / 100
        else
          stat.value
        end
      end
    end
  end

  def update_stats(attrs)
    attrs.keys.each do |ic|
      unless attrs[ic].blank?

        new_value = if MonthlyStat.is_a_rate?(ic)
          # rates are represented as 'cents' in integer.
          attrs[ic].gsub(",",".").to_f * 100
        else
          attrs[ic]
        end

        stat = monthly_stats(ic)
        if stat.nil?
          # create
          stat = SchoolMonthlyStat.new
          stat.school_id = @school.id
          stat.ref_date = @ref_date.end_of_month
          stat.name = ic
          stat.service = nil
          stat.value = new_value
          stat.save
        else
          # TODO check if service is local !!! 
          stat.update_attribute :value, new_value
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

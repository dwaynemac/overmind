class Checksum
  
  # return TRUE if ok.
  # return FALSE if global students for given month doesnt match:
  # prev_month_students + cur_month_enrollments - cur_month_dropouts
  def self.global_students(options)
    ref_month = options[:ref_month]
    
    # acum is expected ref_month students
    acum = SchoolMonthlyStat.where(name: :students)
                     .for_month(ref_month - 1.month)
                     .sum(:value)
    acum += SchoolMonthlyStat.where(name: :enrollments)
                        .for_month(ref_month)
                        .sum(:value)
    acum -= SchoolMonthlyStat.where(name: :dropouts)
                             .for_month(ref_month)
                             .sum(:value)
    
    
    acum == SchoolMonthlyStat.where(name: :students)
                             .for_month(ref_month)
                             .sum(:value)
  end
  
  def self.students(options)
    school_ids = get_school_ids(options)
    return nil if school_ids.nil?
    ref_month = options[:ref_month]
    
    prev_month_students = value_for(:students,ref_month-1.month,school_ids) || 0
    cur_month_enrollments = value_for(:enrollments,ref_month,school_ids) || 0
    cur_month_dropouts = value_for(:dropouts,ref_month,school_ids) || 0
    cur_month_students = value_for(:students,ref_month,school_ids)
     
    begin
      prev_month_students + cur_month_enrollments - cur_month_dropouts == cur_month_students  
    rescue NoMethodError # catch if any value was nil
      false
    end
  end
  
  private
  
  def self.get_school_ids(options)
    if options[:school_id]
      options[:school_id]
    elsif options[:account_name]
      School.where(account_name: options[:account_name]).first.try(:id)
    end
  end
  
  def self.value_for(stat_name, ref_date, school_ids)
    ms = SchoolMonthlyStat.where(school_id: school_ids,
                                 name: stat_name)
                          .for_month(ref_date)
    ms.first.try(:value)
  end

  
end
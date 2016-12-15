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
    school = if options[:school_id]
      School.find options[:school_id]
    elsif options[:account_name]
      School.where(account_name: options[:account_name]).first
    end
    return nil if school.nil?
    
    ref_month = options[:ref_month]
    
    # acum is expected ref_month students
    acum = school.school_monthly_stats.where(name: :students)
                     .for_month(ref_month - 1.month)
                     .sum(:value)
    acum += school.school_monthly_stats.where(name: :enrollments)
                        .for_month(ref_month)
                        .sum(:value)
    acum -= school.school_monthly_stats.where(name: :dropouts)
                             .for_month(ref_month)
                             .sum(:value)
    
    
    acum == school.school_monthly_stats.where(name: :students)
                             .for_month(ref_month)
                             .sum(:value)
  end
end
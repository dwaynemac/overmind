# return TRUE if value is ok.
# return FALSE if value doesnt match:
class Checksum
  
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
    @check = true
    ref_month = options[:ref_month]
    
    cur_month_students = value_for(:students,ref_month,school_ids)
    if cur_month_students.nil?
      log "no data for current month"
      return false # no data for cur_month, sync!
    end
    
    if @check
      # check prev students + enroll - drops
      prev_month_students = value_for(:students,ref_month-1.month,school_ids) || 0
      cur_month_enrollments = value_for(:enrollments,ref_month,school_ids) || 0
      cur_month_dropouts = value_for(:dropouts,ref_month,school_ids) || 0
       
      begin
        @check &&= (prev_month_students + cur_month_enrollments - cur_month_dropouts == cur_month_students  )
      rescue
        @check &&= false
      end
      unless @check
        log "failed enrolls drops check"
      end
    end
    
    if @check
      begin
        levels = [:aspirante_students,
         :sadhaka_students, :yogin_students, :chela_students, :graduado_students,
         :assistant_students, :professor_students, :master_students ]
        students_by_levels = 0
        levels.each do |level|
          students_by_levels += value_for(level,ref_month,school_ids)
        end
        @check &&= (cur_month_students == students_by_levels)
      rescue 
        @check &&= false
      end
      unless @check
        log "failed levels check"
      end
    end
    
    if @check
      begin
        students_by_gender = 0
        [:male_students, :female_students].each do |gender|
          students_by_gender += value_for(gender,ref_month,school_ids)
        end
        @check &&= (cur_month_students == students_by_gender)
      rescue
        @check &&= false
      end
      unless @check
        log "failed gender check"
      end
    end
    
    if @check
      begin
        students_by_teachers = TeacherMonthlyStat.where(school_id: school_ids,
                                 name: :students,
                                 ref_date: ref_month).sum(:value) 
        @check &&= (students_by_teachers == cur_month_students)
      rescue
        @check &&= false
      end
      unless @check
        log "failed teachers check"
      end
    end
    
    @check
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

  def self.log(msg)
    puts msg
  end

  
end

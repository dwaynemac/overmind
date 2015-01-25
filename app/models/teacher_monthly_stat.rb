class TeacherMonthlyStat < MonthlyStat
  attr_accessible :teacher_id
  belongs_to :teacher

  STATS_BY_TEACHER = [
      :students,

      :male_students,
      :female_students,

      :aspirante_students,  # students at Aspirante lev
      :sadhaka_students,  # students at Sádhaka lev
      :yogin_students,  # students at Yôgin lev
      :chela_students,  # students at Chêla lev
      :graduado_students,  # students at Graduado lev
      :assistant_students, # students at Assistant lev
      :professor_students, # students at Professor level.
      :master_students, # students at Master level.

      :enrollments,
      :dropouts,

      :enrollment_rate,
      :dropout_rate,

      :demand,
      :interviews, :p_interviews,
      :emails, :phonecalls,

      :conversion_rate
  ]

  ##
  # Will fetch all stats in STATS_BY_TEACHER from corresponding service (according to school)
  # for month of ref_date.
  # @param school [School]
  # @param name [Symbol] stat name
  # @param ref_date [Date]
  # @return --
  def self.sync_school_from_service(school,name,ref_date)

    unless STATS_BY_TEACHER.include?(name)
      raise ArgumentError, 'this stats is not available on a teacher granularity level.'
    end

    # ensure the date is at end of month.
    ref_date = ref_date.to_date.end_of_month

    service = MonthlyStat.service_for(school,name,ref_date)
    if service == 'overmind'
      school.teachers.each do |teacher|
        value = self.calculate_local_value(school,teacher,name,ref_date)
        create_or_update(school,teacher,name,ref_date,value) if value
      end
    else
      teachers_stats = self.get_remote_values(school,name,service,ref_date) || []

      teachers_stats.each do |tstat|

        tstat.stringify_keys!

        # get teacher
        teacher = Teacher.smart_find(tstat['padma_username'],tstat['full_name'],school)

        create_or_update(school,teacher,name,ref_date,tstat['value'])
      end
    end
  end

  def self.create_or_update(school,teacher,name,ref_date,value)
    existing = self.where(school_id: school.id,
                          teacher_id: teacher.id,
                          name: name,
                          ref_date: ref_date)
    if existing.empty?
      # store new
      self.create(school_id: school.id,
                  teacher_id: teacher.id,
                  name: name,
                  ref_date: ref_date,
                  value: value)
    else
      # update existing
      teacher_stat = existing.first
      teacher_stat.value = value
      teacher_stat.save
    end
  end

  def self.calculate_local_value(school,teacher,stat_name,ref_date)
    ls = LocalStat.new(name: stat_name,
                       ref_date: ref_date,
                       school: school,
                       teacher: teacher
                      )
    ls.value
  end

  # Will delegate fetching value to a corresponding module according to
  # service.
  # @param school [School]
  # @param name [String] stat name
  # @param service [String] service from which to fetch stat
  # @param ref_date [Date]
  # @return [Array<Hash>]
  def self.get_remote_values(school,name,service,ref_date)
    return nil if service.blank?
    case service
      when 'kshema'
        school.fetch_stat(name,ref_date,by_teacher: true)
      when 'crm'
        school.fetch_stat_from_crm(name,ref_date,by_teacher: true)
      else
        raise 'unknown service'
    end
  end
end

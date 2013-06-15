class TeacherMonthlyStat < MonthlyStat
  attr_accessible :teacher_id
  belongs_to :teacher

  STATS_BY_TEACHER = [
      :students,

      :enrollments,
      :dropouts,

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

    service = MonthlyStat.service_for(school,name)
    teachers_stats = self.get_remote_values(school,name,service,ref_date) || []

    teachers_stats.each do |tstat|

      tstat.stringify_keys!

      # get teacher
      teacher = Teacher.smart_find(tstat['padma_username'],tstat['full_name'],school)

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
                     value: tstat['value'])
      else
        # update existing
        teacher_stat = existing.first
        teacher_stat.value = tstat['value']
        teacher_stat.save
      end
    end
  end

  # Will delegate fetching value to a corresponding module according to
  # service.
  # @param school [School]
  # @param name [String] stat name
  # @param service [String] service from which to fetch stat
  # @param ref_date [Date]
  # @return [Array<Hash>]
  def self.get_remote_values(school,name,service,ref_date)
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

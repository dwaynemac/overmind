# MonthlyStat represents statistic for a *month*
# = Attributes
#
# * :ref_date is last day of such month.
# * :name [String] name of the statistic.
# * :service name of service from wich this stat was extracted. If nil then stat was manually registered.
# * :value
#
class MonthlyStat < ActiveRecord::Base

  attr_accessible :value, :name, :school_id, :ref_date, :service, :account_name, :id

  VALID_NAMES = [:enrollments,
                 :dropouts,
                 :students,
                 :aspirante_students,  # students at Aspirante lev
                 :sadhaka_students,  # students at Sádhaka lev
                 :yogin_students,  # students at Yôgin lev
                 :chela_students,  # students at Chêla lev
                 :graduado_students,  # students at Graduado lev
                 :assistant_students, # students at Assistant lev
                 :professor_students, # students at Professor level.
                 :master_students, # students at Master level.
                 :demand,
                 :interviews, :p_interviews,
                 :emails, :phonecalls
  ]
  RATES = [:dropout_rate, :enrollment_rate]

  belongs_to :school
  validates_presence_of :school
  validates_presence_of :name
  validates_presence_of :ref_date
  validates_presence_of :value

  before_validation :cast_ref_date_to_date
  before_validation :move_ref_date_to_end_of_month
  validate :ref_date_is_end_of_month

  after_save :cache_student_count, unless: ->{self.importing?}
  after_save :cache_teachers_count, unless: ->{self.importing?}

  validates_uniqueness_of :name, scope: [:school_id, :ref_date]

  def self.for_month(ref_date)
    where(ref_date: ref_date.to_date.end_of_month)
  end

  def self.for_year(year)
    year = year.to_i
    where(ref_date: (Date.civil(year,1,1)..Date.civil(year,12,31)))
  end

  def self.to_matrix
    matrix = Hash.new({})

    # fetch from DB grouped by name.
    self.scoped.group_by(&:name).each_pair do |stat_name, stats|
      # TODO ERROR: if stat has not been scoped to a year this will acumulate all months
      matrix[stat_name] = stats.group_by{|ms|ms.ref_date.month}
    end

    # reduce each month to a total
    matrix.each_pair do |stat_name,stats_by_month|
      stats_by_month.each_pair do |month,stats|
        if stats.size>1
          matrix[stat_name][month] = ReducedStat.new(
              value: stats.sum(&:value),
              ref_date: stats.last.ref_date
          )
        else
          matrix[stat_name][month] = stats.first
        end
      end
    end

    matrix.symbolize_keys!

    # dropout_rate
    matrix[:dropout_rate] = {}
    matrix[:dropouts].each_pair do |month,stat|
      students = nil
      if month > 1
        students = matrix[:students][month-1].try(:value)
      else
        # reproduce current scope removing conditions on ref_date
        students = self.unscoped.joins(self.scoped.joins_values).where(self.scoped.where_clauses.reject{|c|c=~/ref_date/}).where(ref_date: (stat.ref_date-1.month), name: 'students').sum(:value)
      end

      if students && students > 0
        drops = matrix[:dropouts][month].try(:value) || 0
        matrix[:dropout_rate][month] = ReducedStat.new(value: drops.to_f / students.to_f)
      end
    end

    # enrollment_rate
    matrix[:enrollment_rate] = {}
    matrix[:enrollments].each_key do |month|
      interviews = matrix[:p_interviews][month].try(:value)
      if interviews && interviews > 0
        enrollments = matrix[:enrollments][month].try(:value) || 0
        matrix[:enrollment_rate][month] = ReducedStat.new(value: enrollments.to_f / interviews.to_f)
      end
    end

    matrix
  end

  def importing=(v)
    @importing = v
  end

  def importing?
    !!@importing
  end

  def cache_student_count
    # TODO dont run if this stat is not :students
    self.school.cache_last_student_count
  end

  def cache_teachers_count
    # TODO dont run if this stat is not :assistante_students, etc
    self.school.cache_last_teachers_count
  end

  # creates a new MonthlyStat fetching value from remote service.
  # @param [School] school
  # @param [String] name. Statistic code name
  # @param [Date] ref_date
  # @example @school.monthly_stats.create_from_service!(:enrollments, Date.today)
  # @raise exception if creation fails
  # @return [MonthlyStat/NilClass]
  def self.create_from_service!(school,name,ref_date)
    ms = school.monthly_stats.new(name: name, ref_date: ref_date)

    if school.padma2_enabled?
      ms.service = case name.to_sym
        when :students, :enrollments, :dropouts, :demand, :interviews, :p_interviews, :emails, :phonecalls, :aspirante_students, :sadhaka_students, :yogin_students, :chela_students, :graduado_students, :assistant_students, :professor_students, :master_students
          'crm'
      end
    else
      ms.service = 'kshema'
    end

    remote_value = ms.get_remote_value

    if remote_value
      ms.value = remote_value
    end

    ms.save ? ms : nil
  end

  # updates value
  # @return [Integer] new value
  def update_from_service!
    unless service.blank?
      remote_value = get_remote_value
      if remote_value && remote_value.to_i != self.value.to_i
        self.update_attributes value: remote_value
      else
        nil
      end
    end
  end

  def as_json(args={})
    args = {methods: [:account_name], except: [:school_id]}.merge(args)
    super(args)
  end

  def account_name=(name)
    self.school = School.where(account_name: name).last
  end

  def account_name
    school.try :account_name
  end

  def get_remote_value
    case service
      when 'kshema'
        school.fetch_stat(name,ref_date)
      when 'crm'
        case self.name.to_sym
          when :students
            school.count_students(ref_date)
          when :aspirante_students
            school.count_students(ref_date, level: 'aspirante')
          when :sadhaka_students
            school.count_students(ref_date, level: 'sadhaka')
          when :yogin_students
            school.count_students(ref_date, level: 'yogin')
          when :chela_students
            school.count_students(ref_date, level: 'chela')
          when :graduado_students
            school.count_students(ref_date, level: 'graduado')
          when :assistant_students
            school.count_students(ref_date, level: 'asistente')
          when :professor_students
            school.count_students(ref_date, level: 'docente')
          when :master_students
            school.count_students(ref_date, level: 'maestro')
          when :enrollments
            school.count_enrollments(ref_date)
          when :dropouts
            school.count_drop_outs(ref_date)
          when :demand
            school.count_communications(ref_date)
          when :interviews
            school.count_interviews(ref_date)
          when :p_interviews
            school.count_interviews(ref_date, filter: { coefficient: 'p' })
          when :emails
            school.count_communications(ref_date, filter: {media: 'email'})
          when :phonecalls
            school.count_communications(ref_date, filter: { media: 'phone_call'})
        end
    end
  end

  private

  def cast_ref_date_to_date
    unless self.ref_date.nil? || self.ref_date.is_a?(Date)
      self.ref_date = self.ref_date.to_date
    end
  end

  def move_ref_date_to_end_of_month
    return if self.ref_date.nil?
    self.ref_date = self.ref_date.to_date.end_of_month
  end

  def ref_date_is_end_of_month
    return if self.ref_date.nil?
    if self.ref_date.to_date.end_of_month != ref_date
      errors.add(:ref_date, t('errors.attributes.ref_date.not_end_of_month'))
    end
  end
end

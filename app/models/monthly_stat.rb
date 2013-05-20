# encoding: utf-8
# @restful_api v0
# MonthlyStat represents statistic for a *month*
#
# @property [Date] ref_date is last day of such month.
# @property [String] name name of the statistic.
# @property [String] service name of service from which this stat was extracted. If nil then stat was manually registered.
# @property [Integer] value
class MonthlyStat < ActiveRecord::Base

  # Adds methods to build stats matrix.
  include StatsMatrix

  attr_accessible :value, :name, :school_id, :ref_date, :service, :account_name, :id   # account name is an accessor, delegated to School.

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

  before_save :set_type

  validates_presence_of :name
  validates_presence_of :ref_date
  validates_presence_of :value

  before_validation :cast_ref_date_to_date
  before_validation :move_ref_date_to_end_of_month
  validate :ref_date_is_end_of_month

  after_save :cache_student_count, unless: ->{self.importing?}
  after_save :cache_teachers_count, unless: ->{self.importing?}


  def self.for_month(ref_date)
    where(ref_date: ref_date.to_date.end_of_month)
  end

  def self.for_year(year)
    year = year.to_i
    where(ref_date: (Date.civil(year,1,1)..Date.civil(year,12,31)))
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



  ##
  # According to stat name and school this will set from wich service value needs to be fetched.
  # @param school [School]
  # @param stat_name [Symbol]
  # @return [String]
  def set_service
    self.service = MonthlyStat.service_for(self.school,self.name)
  end

  # @param school [School]
  # @param name [String] a valid stat name
  # @return [String]
  def self.service_for(school,name)
    if school.padma2_enabled?
      case name.to_sym
        when :students, :enrollments, :dropouts, :demand, :interviews, :p_interviews, :emails, :phonecalls,
            :aspirante_students, :sadhaka_students, :yogin_students, :chela_students, :graduado_students, :assistant_students, :professor_students, :master_students
          'crm'
        else
          raise 'statistic not mapped to a service'
      end
    else
      'kshema'
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

  def set_type
    if teacher_id.nil?
      self.type = 'SchoolMonthlyStat'
    end
  end
end

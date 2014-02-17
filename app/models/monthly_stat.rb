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
                 :dropouts_begginers,

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

                 :demand,
                 :interviews, :p_interviews,
                 :emails, :phonecalls,
                 :website_contact,
                 :conversion_rate
  ]
  RATES = [:dropout_rate, :enrollment_rate] # reduced values.

  belongs_to :school

  before_validation :set_type # this doesn't make subType validations to run.
  before_validation :cast_ref_date_to_date
  before_validation :move_ref_date_to_end_of_month

  validates_uniqueness_of :name, scope: [:school_id, :teacher_id, :ref_date]
  validates_presence_of :school
  validates_presence_of :name
  validates_presence_of :ref_date
  validates_presence_of :value
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
    self.service = MonthlyStat.service_for(self.school,self.name,self.ref_date)
  end

  def self.service_for(school,stat_name,ref_date)
    if school.account_name.blank?
      nil
    else
      migrated_to_padma_on = school.account.migrated_to_padma_on.try(:to_date)
      if migrated_to_padma_on.nil? || ref_date < migrated_to_padma_on
        'kshema'
      else
        # stat_name could be used here to divide stats between different PADMA modules
        'crm'
      end
    end
  end

  def is_a_rate?
    MonthlyStat.is_a_rate?(self.name)
  end

  def self.is_a_rate?(name)
    name = name.to_sym
    (name == :conversion_rate) || RATES.include?(name)
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

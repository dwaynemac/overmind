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
  
  include SearchUrls

  attr_accessible :value, :name, :school_id, :ref_date, :service, :account_name, :id   # account name is an accessor, delegated to School.

  # IMPORTANT
  # Stats are synced in THIS order
  VALID_NAMES = [
                 :students,

                 :dropouts,
                 :dropout_rate, # depends of :dropouts and :students of previous month

                 :enrollments,
                 :male_enrollments,
                 :p_interviews,
                 :male_p_interviews,
                 :enrollment_rate, # dependes of :enrollments and :p_interviews
                 :male_enrollment_rate, # dependes of :male_enrollments and :male_p_interviews

                 :male_students,
                 :female_students,

                 :male_students_rate,

                 :students_average_age,

                 :aspirante_students,  # students at Aspirante lev
                 :sadhaka_students,  # students at Sádhaka lev
                 :yogin_students,  # students at Yôgin lev
                 :chela_students,  # students at Chêla lev
                 :graduado_students,  # students at Graduado lev
                 :assistant_students, # students at Assistant lev
                 :professor_students, # students at Professor level.
                 :master_students, # students at Master level.

                 :dropouts_begginers,
                 :dropouts_intermediates,

                 :begginers_dropout_rate,
                 :swasthya_dropout_rate,

                 :aspirante_students_rate,
                 :sadhaka_students_rate,
                 :yogin_students_rate,
                 :chela_students_rate,

                 :in_professional_training,

                 :demand,
                 :male_demand, :female_demand,
                 :male_demand_rate, :female_demand_rate,

                 :interviews,
                 :male_interviews, :female_interviews,
                 :male_p_interviews,
                 :male_interviews_rate, :female_interviews_rate,

                 :emails, :phonecalls,
                 :website_contact,
                 :messaging_comms,
                 :social_comms,
                 :conversion_rate, :conversion_count
  ]

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


  def self.api_where(conditions={})
    ret = self.scoped
    return ret if conditions.blank?

    if conditions[:month] && conditions[:year]
      month = conditions.delete(:month).to_i
      year = conditions.delete(:year).to_i
      ref_date = Date.civil(year,
                            month,
                            1).end_of_month
      ret = ret.where(ref_date: ref_date)
    end

    if conditions[:account_name]
      s = School.find_by_account_name(conditions.delete(:account_name))
      if s
        ret = ret.where(school_id: s.id)
      else
        ret = ret.where("1 = 0") # force empty
      end
    end

    ret.where(conditions)
  end

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
    # TODO dont run if this stat is not :assistant_students, etc
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
    new_service = MonthlyStat.service_for(self.school,self.name,self.ref_date)
    self.service = new_service unless new_service.nil?
  end

  def self.service_for(school,stat_name,ref_date)
    if LocalStat.is_local_stat?(stat_name)
      'overmind'
    elsif school.account_name.blank?
      ''
    else
      account = school.account
      if account.nil?
        nil
      else
        migrated_to_padma_on = account.migrated_to_padma_on.try(:to_date)
        if migrated_to_padma_on.nil? || ref_date < migrated_to_padma_on
          'kshema'
        else
          # stat_name could be used here to divide stats between different PADMA modules
          'crm'
        end
      end
    end
  end

  def is_a_rate?
    MonthlyStat.is_a_rate?(self.name)
  end

  def self.is_a_rate?(name)
    name = name.to_sym
    name.in?([
      :conversion_rate,
      :begginers_dropout_rate,
      :swasthya_dropout_rate,
      :enrollment_rate,
      :male_enrollment_rate,
      :dropout_rate,

      :male_students_rate,

      :male_demand_rate, :female_demand_rate,
      :male_interviews_rate, :female_interviews_rate,

      :aspirante_students_rate,
      :sadhaka_students_rate,
      :yogin_students_rate,
      :chela_students_rate
    ])
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

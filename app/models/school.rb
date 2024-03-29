require 'appsignal'
require 'appsignal/integrations/object'

class School < ActiveRecord::Base
  #attr_accessible :name, :federation_id, :nucleo_id, :account_name, :migrated_kshema_to_padma_at

  belongs_to :federation

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :monthly_stats, dependent: :destroy

  has_many :school_monthly_stats
  has_many :teacher_monthly_stats

  has_many :sync_requests

  has_and_belongs_to_many :teachers, join_table: 'schools_teachers'

  include NucleoApi
  include KshemaApi

  include PadmaStatsApi
  # Appsignal measurements for PadmaStatsApi
  appsignal_instrument_method :get_conversion_count
  appsignal_instrument_method :get_conversion_rate
  appsignal_instrument_method :count_students
  appsignal_instrument_method :students_average_age
  appsignal_instrument_method :count_communications
  appsignal_instrument_method :count_drop_outs
  appsignal_instrument_method :count_enrollments

  include Accounts::BelongsToAccount
  validates_uniqueness_of :account_name, allow_blank: true

  scope :enabled_on_nucleo, -> {where("(cached_nucleo_enabled IS NULL) OR cached_nucleo_enabled")}
  scope :enabled_on_padma, -> {where("(cached_padma_enabled IS NULL) OR cached_padma_enabled")}

  # avoid calling accounts-ws to get the name.
  # if PadmaAccount cached call full_name on it
  # if PadmaAccount NOT cached use name cached on db.
  def quick_name
    padma_account.present?? full_name : name
  end

  def full_name
    account.nil? ? name : account.full_name
  end

  ##
  # Checks if this schools has pending sync_requests
  # @return [Boolean]
  def pending_sync_requests?(year=nil, month= nil)
    sync_requests.on_ref_date({year: year, month: month}).pending.count > 0
  end

  ##
  # Checks if this schools has failed sync_requests
  # @return [Boolean]
  def failed_sync_requests?(year=nil, month= nil)
    sync_requests.on_ref_date({year: year, month: month}).failed.count > 0
  end

  ##
  # Syncs all stats of given year. School and Teacher
  # @param year [Integer]
  # @param options [Hash]
  # @option options :update_existing (false)
  # @option options :skip_teachers (false)
  def sync_year_stats(year,options={})
    months_range = (year == Time.zone.today.year)? (1..Time.zone.today.month) : (1...13)
    months_range.each do |month|
      sync_school_month_stats(year,month,options.merge({skip_synced_at_setting: true}))
      unless options[:skip_teachers]
        sync_teacher_monthly_stats(year,month)
      end
    end
    self.update_attribute(:synced_at,Time.now)
  end

  ##
  # Updates teacher_monthly_stats.
  # @param year [Integer]
  # @param month [Integer]
  def sync_teacher_monthly_stats(year,month)
    ref = ref_date(year,month)
    TeacherMonthlyStat::STATS_BY_TEACHER.each do |name|
      TeacherMonthlyStat.sync_school_from_service(self,name,ref)
    end
  end

  ##
  # Updates all schools_monthly_stats of this school for given month
  # @param year [Integer]
  # @param month [Integer]
  # @param options [Hash]
  # @option options :update_existing (false)
  # @option options :skip_synced_at_setting (false)
  def sync_school_month_stats(year,month,options={})
    ref = ref_date(year,month)
    MonthlyStat::VALID_NAMES.each do |name|
      SchoolMonthlyStat.sync_from_service!(self, name, ref, async: true)
      #stats_for_month = self.school_monthly_stats.where(name: name).for_month(ref)
      #if stats_for_month.empty?
        #SchoolMonthlyStat.create_from_service!(self,name,ref)
      #else
        #if options[:update_existing]
          #stats_for_month.last.update_from_service!
        #end
      #end
    end
    unless options[:skip_synced_at_setting]
      self.update_attribute(:synced_at, Time.now)
    end
  end

  # Check on SecreatariaVirtual if school is enabled.
  # @return nil on Connection Problems
  # @return [TrueClass]
  def nucleo_enabled?
    cached_nucleo_enabled
=begin
    TODO disable until nucleo back online
    ret = !!(self.api.try(:uni_status) == '1')
    update_attribute :cached_nucleo_enabled, ret
    ret
=end
  end

  # @return nil on Connection Problems
  # @return [TrueClass]
  def padma_enabled?
    ret = nil
    if self.account_name.present?
      if self.account.present?
        ret = self.account.enabled?
        update_attribute :cached_padma_enabled, ret
      end
    end
    ret
  end

  # Difference: stored for school - calculated from teachers
  # @return [Integer] diference between value stored as total for school and sum of teachers values.
  def diff(ref_date,stat_name)
    absolute = school_monthly_stats.for_month(ref_date).where(name: stat_name).sum(:value)
    calculated = teacher_monthly_stats.for_month(ref_date).where(name: stat_name).sum(:value)
    absolute - calculated
  end

  # Check if stat stored for school matched calculated by teachers
  # @return [Boolean]
  def exact?(ref_date,stat_name)
    (diff(ref_date,stat_name) == 0)
  end

  def relative_students_count?
    self.count_students_relative_to_value && self.count_students_relative_to_date
  end
  private

  # @param year [Integer]
  # @param month [Integer]
  # @return Date.civil
  def ref_date(year,month)
    Date.civil(year.to_i,month.to_i,1)
  end

end

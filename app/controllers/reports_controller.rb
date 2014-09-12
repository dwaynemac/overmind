class ReportsController < ApplicationController
  layout 'reports'

  include ReportsHelper

  before_filter :load_school
  authorize_resource :school

  before_filter :set_ref_date
  before_filter :set_stats_scope
  
  def marketing_snapshot
    authorize! :read, :reports

    @emails = get_value(:emails) + get_value(:website_contact)
    @calls = get_value :phonecalls
    @visits = get_value :interviews
    @perfil = get_value :p_interviews
    @fp = @visits - @perfil
    @enrollments = get_value :enrollments
    @convertion = get_value :conversion_rate
    @demand = get_value :demand
  end

  def pedagogic_snapshot
    authorize! :read, :reports

    unless fragment_exist? pedagogic_snapshot_cache_key(params[:year],params[:month])
      #widget
      @enrollments = get_value :enrollments
      @dropouts = get_value :dropouts
      @students = get_value :students
      @growth = @enrollments - @dropouts
      
      #graph
      @begginers = get_value :aspirante_students
      @sadhakas = get_value :sadhaka_students
      @yogins = get_value :yogin_students
      @chelas = get_value :chela_students
      @graduados = get_value :graduado_students
      @assistants = get_value :assistant_students
      @professors = get_value :professor_students
      
      #left pie chart
      males = get_value :male_students
      females = get_value :female_students
      if males+females > 0
        @male_students = (males.to_f/(males+females)*100).round(0)
        @female_students = (females.to_f/(males+females)*100).round(0)
      else
        @male_students = 0
        @female_students = 0
      end

      @students_avg_age = get_value :students_average_age

      
      #right pie chart
      @begginer = 60
      @graduate = 30
      @senior = 10
    end
  end

  def refresh
    authorize! :create, SyncRequest

    resp = ""
    if @school.sync_requests.in_progress.where(year: @year).count > 0
      resp = t('schools.sync_request_notification_running_sync', progress: @school.sync_requests.in_progress.last.progress)
    elsif @school.failed_sync_requests?(@year)
      resp = t('schools.sync_request_notification.failed_sync')
    elsif (sr = @school.sync_requests.where(year: @year).pending.last)
      sr.update_attributes priority: 15
      resp = t('schools.sync_request_notification_running_sync', progress: sr.progress)
    else
      sr = @school.sync_requests.create(priority: 10, year: @year, synced_upto: @month-1)
      resp = t('schools.sync_request_notification_running_sync', progress: sr.progress)
    end

    redirect_to return_to_path, notice: resp
  end

  private

  def load_school
    if School.exists?(params[:school_id])
      @school = School.find(params[:school_id])
    else
      @school = School.where(account_name: params[:school_id]).try :first
    end

    if @school.nil?
      raise ActiveRecord::RecordNotFound
    end

    @school
  end

  def return_to_path
    m = params[:return_to].match /(.*)_snapshot/
    "#{school_path(@school)}/reports/#{m[1]}/#{@year}/#{@month}"
  end

  def set_ref_date
    @year = params[:year].try(:to_i)
    @month = params[:month].try(:to_i)

    @ref_date = Date.civil(@year,@month,1).end_of_month
  end

  def set_stats_scope
    @scope = @school.school_monthly_stats.where(ref_date: @ref_date)
  end
  
  def get_value(stat_name)
    (@scope.where(name: stat_name).first.try(:value)) || 0
  end
end

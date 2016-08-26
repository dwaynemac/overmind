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

    preloaded_stats = @scope.all

    #widget
    @enrollments = select_value preloaded_stats,  :enrollments
    @dropouts = select_value preloaded_stats,  :dropouts
    @students = select_value preloaded_stats,  :students
    @growth = @enrollments - @dropouts
    
    #graph
    @begginers = select_value preloaded_stats,  :aspirante_students
    @sadhakas = select_value preloaded_stats,  :sadhaka_students
    @yogins = select_value preloaded_stats,  :yogin_students
    @chelas = select_value preloaded_stats,  :chela_students
    @graduados = select_value preloaded_stats,  :graduado_students
    @assistants = select_value preloaded_stats,  :assistant_students
    @professors = select_value preloaded_stats,  :professor_students
    
    #left pie chart
    males = select_value preloaded_stats,  :male_students
    females = select_value preloaded_stats,  :female_students
    if males+females > 0
      @male_students = (males.to_f/(males+females)*100).round(0)
      @female_students = (females.to_f/(males+females)*100).round(0)
    else
      @male_students = 0
      @female_students = 0
    end

    @students_avg_age = select_value preloaded_stats,  :students_average_age
  end

  def refresh
    authorize! :create, SyncRequest

    resp = ""
    if @school.sync_requests.in_progress.where(year: @year, month: @month).count > 0
      resp = t('schools.sync_request_notification_running_sync')
    elsif @school.failed_sync_requests?(@year, @month)
      resp = t('schools.sync_request_notification.failed_sync')
    elsif (sr = @school.sync_requests.where(year: @year, month: @month).pending.last)
      sr.update_attributes priority: 15
      resp = t('schools.sync_request_notification_running_sync')
    else
      sr = @school.sync_requests.create(priority: 10, year: @year, month: @month)
      resp = t('schools.sync_request_notification_running_sync')
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

  def select_value(preloaded_batch,stat_name)
    (preloaded_batch.select{|sms| sms.name == stat_name }.first.try(:value)) || 0
  end
end

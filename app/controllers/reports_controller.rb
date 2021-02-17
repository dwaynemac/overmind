class ReportsController < ApplicationController
  layout 'reports'

  include ReportsHelper

  before_filter :load_school, except: [:global_teachers]
  authorize_resource :school, except: [:global_teachers]

  before_filter :set_ref_date, except: [:global_teachers]
  before_filter :set_stats_scope, except: [:global_teachers]

  def global_teachers
    authorize! :global_teachers, :reports

    scope = TeacherMonthlyStat.all

    if params[:federation_ids]
      scope = scope.joins(:school).where( schools: { federation_id: params[:federation_ids] })
    elsif params[:school_ids]
      scope = scope.where(school_id: params[:school_ids])
    end
    if params[:stat_names]
      @stat_names = params[:stat_names]
      scope = scope.where(name: params[:stat_names])
    end
    if params[:avg_since] && params[:avg_until]
      scope = scope.where(ref_date: params[:avg_since].to_date..params[:avg_until].to_date )
    elsif params[:ref_date]
      scope = scope.where(ref_date: params[:ref_date])
    end

    @stats = scope.includes(:teacher).group("monthly_stats.name, teacher_id").select("AVG(value) as value, monthly_stats.name as name, teacher_id")
  end
  
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

    unless SyncRequest.on_ref_date(year: @year, month: @month)
                      .where(school_id: @school.id)
                      .where(state: %W(ready running paused))
                      .exists?
      sr = SyncRequest.create(year: @year, month: @month, school_id: @school.id, priority: 10)
      sr.queue_dj
    end

    preloaded_stats = @scope

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
    (preloaded_batch.select{|sms| sms.name.to_sym == stat_name }.first.try(:value)) || 0
  end
end

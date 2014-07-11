class ReportsController < ApplicationController
  layout 'reports'

  load_and_authorize_resource :school

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
      @male_students = (males.to_f/(males+females)).round(2)
      @female_students = (females.to_f/(males+females)).round(2)
    else
      @male_students = 0
      @female_students = 0
    end

    @students_avg_age = get_value :students_avg_age

    
    #right pie chart
    @begginer = 60
    @graduate = 30
    @senior = 10
  end

  private

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

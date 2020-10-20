class TeachersController < ApplicationController

  load_and_authorize_resource except: :show

  def show
    @school = School.find(params[:school_id])
    authorize! :read, @school
    @teacher = Teacher.find params[:id]

    @years = (2010..Date.today.year)
    @year = params[:year] || Date.today.year

    current_school_teachers = @school.account.present?? @school.account.users.map(&:username) : nil
    @teachers = current_school_teachers.blank?? @school.teachers : @school.teachers.select{|t| t.username.in?(current_school_teachers) }
    @stats = Matrixer.new(@school.teacher_monthly_stats.for_year(@year).where(teacher_id: params[:id])).to_matrix
    @stat_names = get_stat_names.map(&:to_sym)
    respond_to do |format|
      format.html
      format.csv do
        response.headers['Content-Disposition'] = "attachment; filename='teacher_#{@teacher.id}_#{@year}.csv'"
        render 'show.csv.erb'
      end
    end
  end

  private

  def get_stat_names
    regular = if params[:ranking] && params[:ranking][:column_names]
      cookies[:anual_report_stats] = params[:ranking][:column_names].reject(&:blank?)
    else
      # default
      if cookies[:anual_report_stats]
        cookies[:anual_report_stats].split("&")
      else
        %W(students dropouts dropout_rate demand conversion_rate p_interviews enrollments enrollment_rate )
      end
    end
    regular + MonthlyStat::MANUAL_STATS
  end
end

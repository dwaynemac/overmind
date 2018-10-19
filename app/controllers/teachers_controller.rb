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
    @stats = @school.teacher_monthly_stats.for_year(@year).where(teacher_id: params[:id]).to_matrix
    respond_to do |format|
      format.html
      format.csv do
        response.headers['Content-Disposition'] = "attachment; filename='teacher_#{@teacher.id}_#{@year}.csv'"
        render 'show.csv.erb'
      end
    end
  end

end

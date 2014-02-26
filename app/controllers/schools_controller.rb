class SchoolsController < ApplicationController

  load_and_authorize_resource except: :show_by_name

  def index
    if @schools.count == 1
      # if current ability can only view 1 school skip index.
      redirect_to @schools.first
    else
      order_by = params[:order] || 'name'
      @q = @schools.search(params[:q])
      @schools = @q.result

      @schools = @schools.order(order_by)
      @schools = @schools.page(params[:page])
    end
  end

  def show_by_name
    @school = School.find_by_account_name(params[:account_name])
    if @school.nil?
      raise ActiveRecord::RecordNotFound
    end
    authorize! :read, @school
    redirect_to @school
  end

  def show
    @years = (2010..Date.today.year)
    @year = params[:year] || Date.today.year

    @school_monthly_stats = @school.school_monthly_stats.for_year(@year).to_matrix

    @teachers_monthly_stats = {}
    @school.teachers.each do |teacher|
      @teachers_monthly_stats[teacher.id] = @school.teacher_monthly_stats.for_year(@year).where(teacher_id: teacher.id).to_matrix
    end
    respond_to do |format|
      format.html
      format.csv do
        response.headers['Content-Disposition'] = "attachment; filename='#{@school.account_name}_#{@year}.csv'"
        render 'show.csv.erb'
      end
    end
  end

  def new

  end

  def create
    if @school.save
      redirect_to schools_path
    else
      render :new
    end
  end

  def edit

  end

  def update
    if @school.update_attributes(params[:school])
      redirect_to schools_path
    else
      render :edit
    end
  end

  def destroy
    @school.destroy
    redirect_to schools_path
  end
end

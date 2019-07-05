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

  def show_by_nucleo_id
    @school = School.find_by_nucleo_id(params[:nid])
    if @school.nil?
      # maybe we are out of sync ? 
      a = PadmaAccount.find_by_nucleo_id params[:nid]
      if a
        @school = School.find_by_account_name(a.name)
        @school.update_attribute :nucleo_id, params[:nid]
      end
    end
    if @school.nil?
      raise ActiveRecord::RecordNotFound
    end
    authorize! :read, @school
    redirect_to @school
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

    @stat_names = get_stat_names.map(&:to_sym)
    @ranking_for_column_names = Ranking.new(column_names: @stat_names)

    stats_scope = @school.school_monthly_stats
      .where(name: @stat_names)
      .for_year(@year)
    # matrix to render table
    @school_monthly_stats = Matrixer.new(stats_scope).to_matrix

    # queue updating all rendered stats
    stats_scope.each{|sms| sms.queue_resync }

    # load teachers for teacher tabs
    current_school_teachers = @school.account.present?? @school.account.users.map(&:username) : nil
    @teachers = current_school_teachers.blank?? @school.teachers : @school.teachers.select{|t| t.username.in?(current_school_teachers) }

    respond_to do |format|
      format.html
      format.csv do
        response.headers['Content-Disposition'] = "attachment; filename=#{@school.account_name}_#{@year}.csv"
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

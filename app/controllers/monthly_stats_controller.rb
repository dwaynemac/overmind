class MonthlyStatsController < ApplicationController

  before_filter :load_monthly_stat, only: [:create]
  load_and_authorize_resource :school, except: [:global]
  load_and_authorize_resource through: :school, except: [:global]

  def index; end

  def new; end

  def show
    respond_to do |format|
      format.json { respond_with_bip(@monthly_stat) }
    end
  end

  def create
    respond_to do |format|
      if @monthly_stat.save
        format.html {redirect_to @school, notice: t('monthly_stats.create.success')}
        format.json do
          render json: {id: @monthly_stat.id}
        end
      else
        format.html {render :new}
        format.json do
          render json: @monthly_stat.errors.full_messages, :status => :unprocessable_entity
        end
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @monthly_stat.update_attributes(monthly_stat_params)
        format.html {redirect_to @school, notice: t('monthly_stats.update.success')}
        format.json do
          render json: {id: @monthly_stat.id}
        end
      else
        format.html {render :edit}
        format.json do
          render json: @monthly_stat.errors.full_messages, :status => :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @monthly_stat.destroy
    respond_to do |format|
      format.html {redirect_to @school}
      format.js {render :layout => false}
    end
  end

  def sync
    @monthly_stat.update_from_service!
    redirect_to school_path(id: @school.id, year: params[:year])
  end

  def sync_create
    ref_date = Date.parse(params[:ref_date])
    SchoolMonthlyStat.create_from_service!(@school,params[:name],ref_date.end_of_month)
    redirect_to school_path(id: @school.id, year: ref_date.year)
end

  def global
    authorize! :see_global, MonthlyStat
    @years = 2010..Date.today.year
    @year = params[:year] || Time.zone.today.year
    stats = MonthlyStat.for_year(@year)
    @monthly_stats = Matrixer.new(stats).to_matrix
    respond_to do |format|
      format.html
      format.csv do
        response.headers['Content-Disposition'] = "attachment; filename='#{@year}_global.csv'"
        render 'global.csv.erb'
      end
    end
  end

  private
  def monthly_stat_params
    params.require(:monthly_stat).permit(
      :value,
      :name,
      :school_id,
      :ref_date,
      :service,
      :account_name,
      :teacher_username,
      :id,
      :unit
    )
  end

  def load_monthly_stat
    @monthly_stat = MonthlyStat.new(monthly_stat_params)
    @monthly_stat.school_id = params[:school_id] if @monthly_stat.school_id.nil?
  end
end

class MonthlyStatsController < ApplicationController

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
          render json: {id: @monthly_stat.id}
        end
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @monthly_stat.update_attributes(params[:monthly_stat])
        format.html {redirect_to @school, notice: t('monthly_stats.update.success')}
        format.json do
          render json: {id: @monthly_stat.id}
        end
      else
        format.html {render :edit}
        format.json do
          render json: {id: @monthly_stat.id}
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

  def global
    authorize! :see_global, MonthlyStat
    @years = 2010..Date.today.year
    @year = params[:year] || Time.zone.today.year
    stats = MonthlyStat.for_year(@year)
    @monthly_stats = Matrixer.new(stats).to_matrix
  end
end

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
    if @monthly_stat.save
      redirect_to @school, notice: t('monthly_stats.create.success')
    else
      render :new
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @monthly_stat.update_attributes(params[:school_monthly_stat])
        format.html {redirect_to @school, notice: t('monthly_stats.update.success')}
        format.json { respond_with_bip(@monthly_stat) }
      else
        format.html {render :edit}
        format.json { respond_with_bip(@monthly_stat) }
      end
    end
  end

  def destroy
    @monthly_stat.destroy
    redirect_to @school
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

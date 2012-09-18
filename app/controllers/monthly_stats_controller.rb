class MonthlyStatsController < ApplicationController

  load_and_authorize_resource :school
  load_and_authorize_resource through: :school

  def index; end

  def new; end

  def create
    if @monthly_stat.save
      redirect_to @school, notice: t('monthly_stats.create.success')
    else
      render :new
    end
  end

  def edit; end

  def update
    if @monthly_stat.update_attributes(params[:monthly_stat])
      redirect_to @school, notice: t('monthly_stats.update.success')
    else
      render :edit
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

end

class FederationsController < ApplicationController

  load_and_authorize_resource

  def index
    @federations = @federations.sort{|a,b|b.schools.count <=> a.schools.count } # @federations.order('name')
  end

  def show
    @years = (2005..Date.today.year)
    @year = params[:year] || Date.today.year
    @monthly_stats = @federation.monthly_stats.for_year(@year).to_matrix
  end

  def new

  end

  def create
    if @federation.save
      redirect_to federations_path, notice: t('federations.create.success')
    else
      render :new
    end
  end

  def edit

  end

  def update
    if @federation.update_attributes(params[:federation])
      redirect_to federations_path, notice: t('federations.update.success')
    else
      render :edit
    end
  end

  def destroy
    @federation.destroy
    redirect_to federations_path, notice: t('federations.destroy.success')
  end

end

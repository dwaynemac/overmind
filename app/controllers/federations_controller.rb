class FederationsController < ApplicationController

  load_and_authorize_resource

  def index
  end

  def show
    @years = (2010..Date.today.year)
    @year = params[:year] || Date.today.year
    @monthly_stats = @federation.school_monthly_stats.for_year(@year).to_matrix
    respond_to do |format|
      format.html
      format.csv do
        response.headers['Content-Disposition'] = "attachment; filename='#{@federation.name}_#{@year}.csv'"
        render 'show.csv.erb'
      end
    end
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

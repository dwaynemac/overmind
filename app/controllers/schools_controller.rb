class SchoolsController < ApplicationController

  load_and_authorize_resource

  def index
    order_by = params[:order] || 'name'
    @schools = @schools.order(order_by)
    @schools = @schools.page(params[:page])
  end

  def show
    @years = (2005..Date.today.year)
    @year = params[:year] || Date.today.year
    @monthly_stats = @school.monthly_stats.for_year(@year).to_matrix
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

  def sync_year
    @school.sync_year_stats(params[:year].to_i,update_existing: true)
    redirect_to school_path(id: @school.id, year: params[:year])
  end
end
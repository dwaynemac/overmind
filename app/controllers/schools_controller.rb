class SchoolsController < ApplicationController

  load_and_authorize_resource

  def index
    @schools = @schools.page(params[:page]).order('name')
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
end
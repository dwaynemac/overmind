class SchoolsController < ApplicationController

  load_and_authorize_resource

  def index
    @schools = @schools.order('name')
  end

  def show
    @year = Date.today.year
    @monthly_stats = @school.monthly_stats.to_matrix
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
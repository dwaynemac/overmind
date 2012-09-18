class SchoolsController < ApplicationController

  load_and_authorize_resource

  def index
    order_by = params[:order] || 'name'
    if params[:federation_id]
      @schools = @schools.where(federation_id: params[:federation_id])
    end
    @schools = @schools.order(order_by)
    @schools = @schools.page(params[:page])
  end

  def show
    @years = (2010..Date.today.year)
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
    if @school.account_name.present?
      @school.sync_year_stats(params[:year].to_i,update_existing: true)
      redirect_to school_path(id: @school.id, year: params[:year])
    else
      redirect_to school_path(id: @school.id, year: params[:year]), error: 'no account_name'
    end
  end
end
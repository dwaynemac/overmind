class IcsController < ApplicationController

  def show
    set_ref_date
    get_school

    if @school.nil?
      raise ActiveRecord::RecordNotFound
    end

    # use a different ability?
    authorize! :read, @school
    
    @ics = Ics.new(@school,@ref_date)
  end

  private

  def get_school
    if params[:school_id]
      @school = School.find params[:school_id] 
    elsif params[:account_name]
      @school = School.find_by_account_name params[:account_name] 
    end
  end

  def set_ref_date
    begin
      @ref_date = Date.parse params[:ref_date]
    rescue
      @ref_date = Time.zone.today
    end
    if @ref_date.nil?
      @ref_date = Time.zone.today
    end
  end
end

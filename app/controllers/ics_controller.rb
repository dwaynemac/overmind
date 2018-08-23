class IcsController < ApplicationController

  # any user can access
  skip_filter :pre_check_access

  before_filter :set_ref_date
  before_filter :get_school
  before_filter :initialize_ics


  def show
    # use a different ability?
    authorize! :read, @school
    render layout: "ics"
  end

  def update
    @ics.update_stats params[:ics]

    redirect_to school_ics_path(ref_date: @ref_date, school_id: @school.id),
                notice: I18n.t('ics.update.updated')
  end

  private

  def initialize_ics
    @ics = Ics.new(@school,@ref_date,params[:ics_options])
  end

  def get_school
    if params[:school_id]
      if (params[:school_id] == "current")
        if current_user.padma_enabled?
          @school = School.find_by_account_name current_user.current_account.name
        end
      else
        @school = School.find params[:school_id] 
      end
    elsif params[:account_name]
      @school = School.find_by_account_name params[:account_name] 
    elsif params[:nucleo_id]
      @school = School.find_by_nucleo_id params[:nucleo_id] 
    end
    if @school.nil?
      raise ActiveRecord::RecordNotFound
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

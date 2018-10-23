class IcsController < ApplicationController

  include IcsHelper

  # any user can access
  skip_before_filter :pre_check_access

  before_filter :set_ref_date, except: [:select_school]
  before_filter :get_school, except: [:select_school]
  before_filter :initialize_ics, except: [:select_school]

  def select_school
    @schools = School.order(:name).map do |s|
      name = s.full_name
      if name.blank?
        name = s.name
      end
      [name,s.id]
    end
    render layout: "ics"
  end

  def show
    @currency = MonthlyStat.new(school_id: @school.id).suggested_currency
    # use a different ability?
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
        else
          redirect_to select_school_ics_path
          return
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
      @ref_date = 1.month.ago.to_date
    end
    if @ref_date.nil?
      @ref_date = 1.month.ago.to_date
    end
  end
end

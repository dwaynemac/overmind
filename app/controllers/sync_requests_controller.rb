class SyncRequestsController < ApplicationController

  load_and_authorize_resource :school
  load_and_authorize_resource through: :school

  def create
    @year = params[:sync_request][:year].try(:to_i)
    if params[:sync_request][:month].nil?
      months = (@year == Time.zone.now.year)? (1..Time.zone.now.month) : (1..12)
      months.each do |month|
        sr = @school.sync_requests.new(params[:sync_request])
        sr.month = month
        sr.save
      end
    else
      @school.sync_requests.create(params[:sync_request])
    end

    redirect_to school_path(id: @school.id,
                            year: @year),
                            notice: I18n.t('schools.sync_year.queued')
  end

  def update
    if @sync_request.update_attributes(params[:sync_request])
      redirect_to school_path(id: @sync_request.school_id,
                              year: @sync_request.year),
                              notice: I18n.t('schools.sync_year.queued')
    else
      redirect_to school_path(id: @sync_request.school_id,
                              year: @sync_request.year),
                              error: I18n.t('schools.sync_year.couldnt_queue_sync')
    end
  end


end

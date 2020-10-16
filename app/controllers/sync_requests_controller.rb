class SyncRequestsController < ApplicationController

  before_filter :load_sync_request
  load_and_authorize_resource :school
  load_and_authorize_resource through: :school

  def create
    @year = params[:sync_request][:year].try(:to_i)
    if params[:sync_request][:month].nil?
      months = (@year == Time.zone.now.year)? (1..Time.zone.now.month) : (1..12)
      months.each do |month|
        sr = @school.sync_requests.new(sync_request_params)
        sr.month = month
        sr.save
        sr.queue_dj
      end
    else
      sr = @school.sync_requests.create(sync_request_params)
      sr.queue_dj
    end


    if params[:return_to]
      redirect_to params[:return_to]
    else
      redirect_to school_path(id: @school.id,
                              year: @year),
                              notice: I18n.t('schools.sync_year.queued')
    end
  end

  def update
    if @sync_request.update_attributes(sync_request_params)
      redirect_to school_path(id: @sync_request.school_id,
                              year: @sync_request.year),
                              notice: I18n.t('schools.sync_year.queued')
    else
      redirect_to school_path(id: @sync_request.school_id,
                              year: @sync_request.year),
                              error: I18n.t('schools.sync_year.couldnt_queue_sync')
    end
  end

  private
  def sync_request_params
    params.require(:sync_request).permit(
      :school_id,
      :year,
      :month,
      :state,
      :synced_at,
      :filter_by_event,
      :priority
    )
  end

  def load_sync_request
    @sync_request = SyncRequest.new(sync_request_params)
  end
end

class SyncRequestsController < ApplicationController

  load_and_authorize_resource :school
  load_and_authorize_resource through: :school

  def create
    @sync_request = @school.sync_requests.new(params[:sync_request])
    if @sync_request.save
      redirect_to school_path(id: @sync_request.school_id,
                              year: @sync_request.year),
                              notice: I18n.t('schools.sync_year.queued')
    else
      redirect_to school_path(id: @sync_request.school_id,
                              year: @sync_request.year),
                              error: I18n.t('schools.sync_year.couldnt_queue_sync')
    end
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

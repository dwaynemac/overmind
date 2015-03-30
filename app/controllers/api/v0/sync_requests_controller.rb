class Api::V0::SyncRequestsController < Api::V0::ApiController

  skip_before_filter :require_api_key, only: [:pause_all]

  # @action POST
  # @url /api/v0/sync_requests/pause_all
  # -- @required [String] api_key
  def pause_all
    SyncRequest.where(state: :running).update_all(state: :paused)
    render json: { message: 'All running syncs now have state "paused"' }
  end
end

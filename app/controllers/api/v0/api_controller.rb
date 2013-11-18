class Api::V0::ApiController < ActionController::Base
  # TODO strip down to ActionController::Metal

  before_filter :require_api_key
  KEY = ENV['api_key']

  private

  def require_api_key
    if params[:api_key] != KEY
      render text: 'Access denied', status: 401
    end
  end

end

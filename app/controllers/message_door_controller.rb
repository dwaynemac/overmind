class MessageDoorController < ApplicationController

  skip_before_filter :mock_login
  skip_before_filter :authenticate_user!
  skip_before_filter :pre_check_access
  skip_before_filter :set_locale


  ##
  #
  # Valid Key Names: subcription_change, trial_lesson, birthday 
  #
  # data MUST include :account_name key EXCEPT for Global Key Names.
  #
  # @argument key_name [String]
  # @argument data [String] JSON encoded
  # @argument secret_key [String]
  def catch
    if params[:secret_key] == ENV['messaging_key']
      # ..
      render json: "received", status: 200
    else
      render json: "wrong secret_key", status: 401
    end
  end

end

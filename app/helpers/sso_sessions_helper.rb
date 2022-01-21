module SsoSessionsHelper

  def get_sso_session
    if signed_in? && sso_session_was_destroyed?
      clear_sso_session_destroyed_flag
      sign_out # refresh session
    end

    unless signed_in?
      redirect_to padma_sso_session_url(
                    new_sso_session_url(destination: request.env["REQUEST_URI"])
                  )
    end
  end

  def sso_session_was_destroyed?
    Rails.cache.read("ssologout_for_#{current_user.username}")
  end

  def set_sso_session_destroyed_flag(username)
    Rails.cache.write("ssologout_for_#{username}",true)
  end

  def clear_sso_session_destroyed_flag
    Rails.cache.delete("ssologout_for_#{current_user.username}")
  end 

  def padma_sso_session_url(return_to_url)
    "#{APP_CONFIG['accounts-url']}/sso/session?rt=#{return_to_url}"
  end

  def padma_sso_logout_url
    "#{APP_CONFIG['accounts-url']}/sso/session/delete"
  end

  # Si enviamos a accounts destination=/admin/dashboard?a=1&b=2&c=3
  # en el retorno params se ve así:
  # {"destination"=>"/admin/dashboard?a=1", "b"=>"2", "c"=>"3", "sso_token"=>"[FILTERED]"}
  # entonces precisamos reconstruir el destination.
  #
  # Este método retorna el destination original
  def destination_with_full_query_string
    if (ret = params[:destination])
      if ret.match(/\?/)
        to_join_params = params.reject{|k| k.in?(%W(destination action controller sso_token))}.permit!.to_param
        ret += "&#{to_join_params}"
      end
    end
    ret
  end

end

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :mock_login

  before_filter :authenticate_user!

  before_filter :pre_check_access

  before_filter :set_locale

  rescue_from CanCan::AccessDenied do
    msg = "AccessDenied"
    if current_user
      msg << " for #{current_user.username}"
      if current_user.padma.try :current_account_name
        msg << " on #{current_user.padma.current_account_name}"
      end
    end
    render text: msg, status: 403
  end

  private

  def mock_login
    if Rails.env.development?
      unless signed_in?
        user = User.find_or_create_by_username("luis.perichon")
        sign_in(user)
      end
    end
  end

  # only CAS users with role or with a PADMA account are allowed
  def pre_check_access
    if signed_in?
      # users with a local role have access to Overmind
      if current_user.role.blank?
        # other users will only access if they have a valid PADMA Account
        unless current_user.padma_enabled?
          raise CanCan::AccessDenied # TODO nice unauthorized window like CRM.
        end
      end
    end
  end

  def set_locale
    if signed_in? && !current_user.locale.blank?
      I18n.locale = current_user.locale
    end
    if params[:locale]
      I18n.locale = params[:locale]
    end
  end

end

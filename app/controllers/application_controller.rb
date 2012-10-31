class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!

  before_filter :pre_check_access

  # TODO set current_account

  before_filter :set_locale

  rescue_from CanCan::AccessDenied do
    render text: 'AccessDenied', status: 403
  end

  private

  # only CAS users with role or with a PADMA account are allowed
  def pre_check_access
    # users with a local role have access to Overmind
    if current_user.role.blank?
      # other users will only access if they have a valid PADMA Account
      unless current_user.padma_enabled?
        raise CanCan::AccessDenied # TODO nice unauthorized window like CRM.
      end
    end
  end

  def set_locale
    if signed_in? && !current_user.locale.blank?
      I18n.locale = current_user.locale
    end
  end

end

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!

  before_filter :set_locale

  rescue_from CanCan::AccessDenied do
    render text: 'AccessDenied', status: 403
  end

  private

  def set_locale
    if signed_in? && !current_user.locale.blank?
      I18n.locale = current_user.locale
    end
  end

end

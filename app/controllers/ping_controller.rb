class PingController < ActionController::Base

  def ping
    render text: "i'm online"
  end

end

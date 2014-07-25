module ApplicationHelper

  # Adds given files to end of body tag
  def javascript(*files)
    content_for(:body_end) { javascript_include_tag(*files) }
  end

  def li(controller,current_controller)
    opts = {}
    opts = opts.merge(class: 'active') if controller == current_controller
    content_tag :li, opts do
      yield
    end
  end

  ##
  # Returns t('monthly_stat.description.stat_name') or nil if not found
  # @param [String] name
  # @return [String]
  def monthly_stat_description(name)
    begin
      I18n.translate("monthly_stat.description.#{name}", raise: true) 
    rescue I18n::MissingTranslationData
      nil
    end
  end

  def generate_secure_doorbell_signature()
      jsonp_secret = 'ekXywafGmn8g60VpE1UclaFPAt4cSBzl2Cpf5gNHCIhZtN6XWWZ088SZQiP48qI5'
      timestamp = Time.now.to_i
      token = SecureRandom.hex(50)

      signature = OpenSSL::HMAC.hexdigest(
                  OpenSSL::Digest::Digest.new('sha256'),
                  jsonp_secret,
                  '%s%s' % [timestamp, token])

      return "timestamp: #{timestamp}, token: '#{token}', signature: '#{signature}', ".html_safe
  end


end

if Rails.env.development?
  require 'localeapp/rails'

  if defined?(Localeapp)
    Localeapp.configure do |config|
      config.api_key = 'KODlDsiQWJPPUI3a1S6dxSGQW6PMeLrryL6zyaM8emd5tH3z17'
    end
  end
end

HYDRA = Typhoeus::Hydra.new

NUCLEO_HOST = case Rails.env
  when 'development'
    'nucleo_api'
  when 'production'
    'metododerose.org/nucleo_api'
end

PADMA_ACCOUNTS_HOST = case Rails.env
  when "production"
    "padma-accounts.herokuapp.com"
  when "development"
    APP_CONFIG['accounts-url'].gsub("http://",'')
  when "test"
    "localhost:3001"
end

module Accounts
  HYDRA = ::HYDRA
  API_KEY = ENV['accounts_key']
  if APP_CONFIG['on-cloud9']
    HOST = PADMA_ACCOUNTS_HOST
  end
end

class LogicalModel
  if Rails.env.production? || Rails.env.staging?
    def self.logger
      Rails.logger
    end
  end
end

module Messaging
  HYDRA = ::HYDRA
  KEY = ENV['messaging_key']
  SNS_KEY_ID = ENV['padma_aws_key_id']
  SNS_SECRET_ACCESS_KEY = ENV['padma_aws_secret_access_key']
end

HYDRA = Typhoeus::Hydra.new

NUCLEO_HOST = case Rails.env
  when 'development'
    'nucleo_api'
  when 'production'
    'metododerose.org/nucleo_api'
end

PADMA_ACCOUNTS_HOST = case Rails.env
  when "production"
    "padma-accounts.heroku.com"
  when "development"
    "localhost:3001"
  when "test"
    "localhost:3001"
end

class LogicalModel
  if Rails.env.production?
    def self.logger
      Rails.logger
    end
  end
end
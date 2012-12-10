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
    "localhost:3001"
  when "test"
    "localhost:3001"
end

module Accounts
  HYDRA = ::HYDRA
  API_KEY = "8c330b5d70f86ebfa6497c901b299b79afc6d68c60df6df0bda0180d3777eb4a5528924ac96cf58a25e599b4110da3c4b690fa29263714ec6604b6cb2d943656"
end

class LogicalModel
  if Rails.env.production?
    def self.logger
      Rails.logger
    end
  end
end

HYDRA = Typhoeus::Hydra.new

NUCLEO_HOST = case Rails.env
  when 'development'
    'nucleo_api'
end

class LogicalModel
  if Rails.env.production?
    def self.logger
      Rails.logger
    end
  end
end

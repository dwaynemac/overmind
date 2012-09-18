# expects base class to have included BelongsToAccount
module KshemaApi

  KEY = "a7ad4703203d9a3a120"

  KSHEMA_HOST = case Rails.env
    when 'development'
      'localhost:3010'
    when 'production'
      'www.metododerose.org/kshema'
    when 'test'
      'mock-me'
  end

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  #  base.send 'hydra=', HYDRA
  end

  module ClassMethods
  end

  module InstanceMethods
    def async_fetch_stat(name, ref_date)
      request = Typhoeus::Request.new(uri, params: {
          key: KEY,
          stat_name: transform_name(name),
          padma_account_name: self.account_name,
          year: ref_date.year,
          month: ref_date.month
      })

      request.on_complete do |response|
        if response.success?
          response.body
        elsif response.timed_out?
          nil
        elsif response.code == 0
          nil
        else
          nil
        end
      end

      self.hydra
    end

    def fetch_stat(name, ref_date)

      response = Typhoeus::Request.get(uri, params: {
          key: KEY,
          stat_name: transform_name(name),
          padma_account_name: self.account_name,
          year: ref_date.year,
          month: ref_date.month
      })

      if response.success?
        response.body
      elsif response.timed_out?
        nil
      elsif response.code == 0
        nil
      else
        nil
      end
    end

    def uri
      KSHEMA_HOST + '/pws/v1/cached_values'
    end

    def transform_name(name)
      transform_name = {
          enrollments: 'EnrollmentCount',
          dropouts: 'DropoutsCount',
          students: 'StudentCount',
          interviews: 'VisitCount',
          p_interviews: 'VisitPCount'
      }
      transform_name[name.to_sym]
    end
  end
end

# expects base class to have included BelongsToAccount
# expects base class to have :hydra attr_accessor
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
  end

  module ClassMethods
  end

  module InstanceMethods

    def async_fetch_stat(name, ref_date)
      if self.account_name.nil?
        return nil
      end
      request = Typhoeus::Request.new(uri, params: {
          key: KEY,
          stat_name: transform_name(name),
          padma_account_name: self.account_name,
          year: ref_date.year,
          month: ref_date.month
      })

      request.on_complete do |response|
        if response.success?
          yield response.body
        elsif response.timed_out?
          nil
        elsif response.code == 0
          nil
        else
          nil
        end
      end

      HYDRA.queue(request)
    end

    def fetch_stat(name, ref_date)
      if self.account_name.nil?
        return nil
      end
      stat = nil
      async_fetch_stat(name,ref_date){|res|stat = res}
      HYDRA.run
      stat
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

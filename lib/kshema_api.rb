# expects base class to have included BelongsToAccount
module KshemaApi

  KEY = "a7ad4703203d9a3a120"

  KSHEMA_HOST = case Rails.env
    when 'development'
      'http://localhost:3010'
    when 'production'
      'https://www.metododerose.org/kshema'
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
          p_interviews: 'VisitPCount',
          assistant_students: 'AsistenteStudentCount',
          professor_students: 'DocenteStudentCount',
          master_students: 'MaestroStudentCount',
      }
      transform_name[name]
    end
  end
end

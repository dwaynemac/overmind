# expects base class to have included Accounts::BelongsToAccount
module KshemaApi

  KEY = "a7ad4703203d9a3a120"

  KSHEMA_HOST = case Rails.env
    when 'development'
      'http://localhost:3010'
    when 'production'
      'https://www.metododerose.org/kshema'
    when 'staging'
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

    # @param name [String]
    # @param ref_date [Date]
    # @param options [Hash]
    # @option options :async (false) queue in hydra but don't run.
    # @option options :hydra (nil)
    # unless :async
    #   @return [String] response body
    # else
    #   @return [Typhoeus::Hydra] hydra with enqueued request.
  def fetch_stat(name, ref_date, options = {})
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

      hydra = options[:hydra] || Typhoeus::Hydra.new
      hydra.queue(request)
      unless options[:async]
        hydra.run
      else
        hydra
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
          aspirante_students: 'AspiranteStudentCount',
          sadhaka_students: 'SadhakaStudentCount',
          yogin_students: 'YoginStudentCount',
          chela_students: 'ChelaStudentCount',
          graduado_students: 'GraduadoStudentCount',
          assistant_students: 'AsistenteStudentCount',
          professor_students: 'DocenteStudentCount',
          master_students: 'MaestroStudentCount',
      }
      transform_name[name.to_sym]
    end
  end
end

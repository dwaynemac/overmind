##
# Methods to interact with Kshema stats api.
# expects base class to have included Accounts::BelongsToAccount
module KshemaApi

  KEY = "a7ad4703203d9a3a120"

  KSHEMA_HOST = case Rails.env
    when 'development'
      'https://www.metododerose.org/kshema'

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

    # @param name [Symbol]
    # @param ref_date [Date]
    # @param options [Hash]
    # @option options [Boolean] by_teacher
    def fetch_stat(name, ref_date,options={})
      return nil if transform_name(name).blank?

      params = {
          key: KEY,
          stat_name: transform_name(name),
          padma_account_name: self.account_name,
          year: ref_date.year,
          month: ref_date.month
      }

      if options[:by_teacher]
        params.merge!({include_teachers: true})
      end

      response = Typhoeus::Request.get(uri, params: params)

      if response.success?
        if options[:by_teacher]
          ActiveSupport::JSON.decode(response.body)
        else
          response.body
        end
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

          aspirante_students: 'AspiranteStudentCount',
          sadhaka_students: 'SadhakaStudentCount',
          yogin_students: 'YoginStudentCount',
          chela_students: 'ChelaStudentCount',
          graduado_students: 'GraduadoStudentCount',
          assistant_students: 'AsistenteStudentCount',
          professor_students: 'DocenteStudentCount',
          master_students: 'MaestroStudentCount',

          demand: 'ProcuraCount',

          interviews: 'VisitCount',
          p_interviews: 'VisitPCount',

          emails: "EmailsCount",
          phonecalls: "PhonecallsCount",

          conversion_rate: "TelevisitToVisitRate"
      }
      transform_name[name.to_sym]
    end
  end
end

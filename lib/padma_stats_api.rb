# encoding: utf-8
# expects base class to have respond to account_name
module PadmaStatsApi


  CONTACTS_URL = case Rails.env
    when 'production'
     'http://contacts.padm.am'
    when 'staging'
     'https://padma-contacts-staging.herokuapp.com'
    else
      'http://localhost:3002'
  end

  CRM_URL = case Rails.env
    when 'production'
      'https://crm.padm.am'
    when 'staging'
      'https://padma-crm-staging.herokuapp.com'
    else
      'http://localhost:3000'
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
    # @option by_teacher [Boolean]
    # @option async [Boolean]
    # @return [Integer/Array<Hash>] will return array if :by_teacher option is given.
    def fetch_stat_from_crm(name,ref_date,options={})
      if ENV["slow_fetch"]
        Rails.logger.info "Slowing down fetch, waiting #{ENV["slow_fetch"]} seconds."
        sleep ENV["slow_fetch"].to_f # espera slow_fetch segundos antes de hacer la llamada, para no sobrecargar
      end
      options[:stat_name] = name if options[:async]
      case name.to_sym
        when :students
          self.count_students(ref_date,options)
        when :aspirante_students
          self.count_students(ref_date, options.merge({level: 'aspirante'}))
        when :sadhaka_students
          self.count_students(ref_date, options.merge({level: 'sádhaka'}))
        when :yogin_students
          self.count_students(ref_date, options.merge({level: 'yôgin'}))
        when :chela_students
          self.count_students(ref_date, options.merge({level: 'chêla'}))
        when :graduado_students
          self.count_students(ref_date, options.merge({level: 'graduado'}))
        when :assistant_students
          self.count_students(ref_date, options.merge({level: 'asistente'}))
        when :professor_students
          self.count_students(ref_date, options.merge({level: 'docente'}))
        when :master_students
          self.count_students(ref_date, options.merge({level: 'maestro'}))
        when :male_students
          self.count_students(ref_date, options.merge({filter: { where: {gender: 'male'}}}))
        when :female_students
          self.count_students(ref_date, options.merge({filter: { where: {gender: 'female'}}}))
        when :students_average_age
          self.students_average_age(ref_date, options)
        when :in_professional_training
          self.count_students(ref_date, options.merge({in_professional_training: true}))
        when :enrollments
          self.count_enrollments(ref_date,options)
        when :male_enrollments
          self.count_enrollments(ref_date,options.merge({filter: {gender: :male}}))
        when :dropouts
          self.count_drop_outs(ref_date,options)
        when :dropouts_begginers
          self.count_drop_outs(ref_date,options.merge({filter: {level: 'aspirante'}}))
        when :dropouts_intermediates
          self.count_drop_outs(ref_date,options.merge({filter: {level: ['sádhaka', 'yôgin', 'chêla', 'graduado', 'asistente', 'docente', 'maestro']}}))
        when :demand
          self.count_communications(ref_date,options)
        when :male_demand
          self.count_communications(ref_date,options.merge({filter: { gender: 'male' }}))
        when :female_demand
          self.count_communications(ref_date,options.merge({filter: { gender: 'female' }}))
        when :interviews
          self.count_interviews(ref_date,options)
        when :male_interviews
          self.count_interviews(ref_date,options.merge({filter: { gender: 'male' }}))
        when :female_interviews
          self.count_interviews(ref_date,options.merge({filter: { gender: 'female' }}))
        when :male_p_interviews
          # option coefficient: 'p' will be interpreted in CRM as :pmenos, :perfil and :pmas
          self.count_interviews(ref_date,options.merge({filter: { gender: 'male', coefficient: 'p' }}))
        when :p_interviews
          # option coefficient: 'p' will be interpreted in CRM as :pmenos, :perfil and :pmas
          self.count_interviews(ref_date, options.merge({filter: { coefficient: 'p' }}))
        when :emails
          self.count_communications(ref_date, options.merge({filter: {media: 'email'}}))
        when :phonecalls
          self.count_communications(ref_date, options.merge({filter: { media: 'phone_call'}}))
        when :website_contact
          self.count_communications(ref_date, options.merge({filter: { media: 'website_contact'}}))
        when :messaging_comms
          self.count_communications(ref_date, options.merge({filter: { media: 'messaging'}}))
        when :social_comms
          self.count_communications(ref_date, options.merge({filter: { media: 'social'}}))
        when :conversion_rate
          self.get_conversion_rate(ref_date,options)
        when :conversion_count
          self.get_conversion_count(ref_date,options)
      end
    end

    # @param ref_date [Date]
    # @param options [Hash]
    def get_conversion_count(ref_date, options={})
      req_options = { app_key: ENV['crm_key'],
                      year: ref_date.year,
                      month: ref_date.month,
                      absolute_value: true
      }
      if options[:by_teacher]
        req_options.merge!({by_teacher: true})
      end


      if options[:async]
        req_options[:async] = options[:async]
        req_options[:stat_name] = options[:stat_name]
        response = Typhoeus::Request.get("#{CRM_URL}/api/v0/accounts/#{self.account_name}/conversion_rate", params: req_options)
        response.code == 202
      else
        response = Typhoeus::Request.get("#{CRM_URL}/api/v0/accounts/#{self.account_name}/conversion_rate", params: req_options)

        res = parse_response(response,!options[:by_teacher])
        if res
          if options[:by_teacher]
            res.each do |h|
              h['value'] = h['value'].to_i
            end
            res
          else
            res.to_i
          end
        end
      end
    end

    # @param ref_date [Date]
    # @param options [Hash]
    def get_conversion_rate(ref_date, options={})
      req_options = { app_key: ENV['crm_key'],
                      year: ref_date.year,
                      month: ref_date.month,
      }
      if options[:by_teacher]
        req_options.merge!({by_teacher: true})
      end

      if options[:async]
        req_options[:async] = options[:async]
        req_options[:stat_name] = options[:stat_name]
        response = Typhoeus::Request.get("#{CRM_URL}/api/v0/accounts/#{self.account_name}/conversion_rate", params: req_options)
        response.code == 202
      else
        response = Typhoeus::Request.get("#{CRM_URL}/api/v0/accounts/#{self.account_name}/conversion_rate", params: req_options)

        res = parse_response(response,!options[:by_teacher])
        if res
          if options[:by_teacher]
            res.each do |h|
              h['value'] = (h['value'].to_f*10000).to_i
            end
            res
          else
            (res.to_f*10000).to_i
          end
        end
      end
    end

    # Fetches students count from CRM-ws
    # @param ref_date [Date]
    # @param options [Hash]
    #
    # @option async [Boolean]
    # @options stat_name [String]
    #
    # @option filter [Hash] Any valid argument for contacts-ws/search
    # @option level [String] Filter by level. Valid values: aspirante, sádhaka, yôgin, chêla, graduado, asistente, docente, maestro
    # @option teacher_username [String] will scope to this specific teacher
    # @option by_teacher [Boolean] will return all teachers -- If :teacher_username is given this will be ignored.
    # Returns array if by_teacher given.
    # @return [Integer/Array<Hash>]
    def count_students(ref_date, options = {})
      req_options = { app_key: ENV['crm_key'],
                      year: ref_date.year,
                      month: ref_date.month
                     }

      if options[:in_professional_training]
        req_options.merge!({
          filter: {
              attribute_values_at: [
                  {attribute: 'in_professional_training', value: options[:in_professional_training]}
              ]
          }
        })
      end

      if options[:level]
        req_options.merge!({
          filter: {
              attribute_values_at: [
                  {attribute: 'level', value: options[:level]}
              ]
          }
        })
      end

      if options[:teacher_username]
        req_options.merge!({
             filter: {
                 attribute_values_at: [
                     {attribute: "local_teacher_for_#{self.account_name}", value: options[:teacher_username]}
                 ]
             }
         })
      elsif options[:by_teacher]
        req_options.merge!({by_teacher: true})
      end

      # do this last to avoid overriding of :filter
      # in previous merges
      if options[:filter].is_a?(Hash)
        if req_options[:filter]
          req_options[:filter].merge!(options[:filter])
        else
          req_options[:filter] = options[:filter]
        end
      end

      if relative_students_count?
        req_options[:relative_to] = {
          date: count_students_relative_to_date,
          value: count_students_relative_to_value
        }
      end

      if options[:async]
        req_options[:async] = options[:async]
        req_options[:stat_name] = options[:stat_name]
        response = Typhoeus::Request.get("#{CRM_URL}/api/v0/accounts/#{self.account_name}/count_students", params: req_options)
        response.code == 202
      else
        response = Typhoeus::Request.get("#{CRM_URL}/api/v0/accounts/#{self.account_name}/count_students", params: req_options)
        parse_response(response,!options[:by_teacher])
      end
    end

    # Fetches students average age
    # @param ref_date [Date]
    # @param options [Hash]
    # @option options [Hash] filter . Any valid argument for contacts-ws/search
    # @option options [String] level. Filter by level. Valid values: aspirante, sádhaka, yôgin, chêla, graduado, asistente, docente, maestro
    #
    # @option async [Boolean]
    # @options stat_name [String]
    #
    # @return [Integer]
    def students_average_age(ref_date, options = {})
      req_options = { app_key: ENV['crm_key'],
                      year: ref_date.year,
                      month: ref_date.month
                     }

      if options[:in_professional_training]
        req_options.merge!({
          filter: {
              attribute_values_at: [
                  {attribute: 'in_professional_training', value: options[:in_professional_training]}
              ]
          }
        })
      end

      if options[:level]
        req_options.merge!({
          filter: {
              attribute_values_at: [
                  {attribute: 'level', value: options[:level]}
              ]
          }
        })
      end

      # do this last to avoid overriding of :filter
      # in previous merges
      if options[:filter].is_a?(Hash)
        if req_options[:filter]
          req_options[:filter].merge!(options[:filter])
        else
          req_options[:filter] = options[:filter]
        end
      end

      if options[:async]
        req_options[:async] = options[:async]
        req_options[:stat_name] = options[:stat_name]
        response = Typhoeus::Request.get("#{CRM_URL}/api/v0/accounts/#{self.account_name}/students_average_age", params: req_options)
        response.code == 202
      else
        response = Typhoeus::Request.get("#{CRM_URL}/api/v0/accounts/#{self.account_name}/students_average_age", params: req_options)
        parse_response(response,true)
      end
    end

    def count_interviews(ref_date, options={})
      options[:filter] ||= {}
      options[:filter].merge!({media: 'interview'})
      count_communications(ref_date,options)
    end

    def count_communications(ref_date,options={})
      req_options = { app_key: ENV['crm_key'],
                      filter: {
                          year: ref_date.year,
                          month: ref_date.month,
                          account_name: self.account_name
                      }
      }
      if options[:filter]
        req_options[:filter].merge! options[:filter]
      end
      req_options.merge!({by_teacher: true}) if options[:by_teacher]

      if options[:async]
        req_options[:async] = options[:async]
        req_options[:stat_name] = options[:stat_name]
        response = Typhoeus::Request.get("#{CRM_URL}/api/v0/communications/count", params: req_options)
        response.code == 202
      else
        response = Typhoeus::Request.get("#{CRM_URL}/api/v0/communications/count", params: req_options)
        parse_response(response,!options[:by_teacher])
      end
    end

    # @param options [Hash]
    # @option options [String] level
    # @option options [String] year
    def count_drop_outs(ref_date,options={})
      req_options = { app_key: ENV['crm_key'],
                      filter: {
                          year: ref_date.year,
                          month: ref_date.month,
                          account_name: self.account_name
                      }
      }
      req_options.merge!({by_teacher: true}) if options[:by_teacher]
      if options[:filter]
        req_options[:filter][:level] = options[:filter][:level] if options[:filter][:level]
      end

      if options[:async]
        req_options[:async] = options[:async]
        req_options[:stat_name] = options[:stat_name]
        response = Typhoeus::Request.get("#{CRM_URL}/api/v0/drop_outs/count", params: req_options)
        response.code == 202
      else
        response = Typhoeus::Request.get("#{CRM_URL}/api/v0/drop_outs/count", params: req_options)
        parse_response(response,!options[:by_teacher])
      end
    end

    def count_enrollments(ref_date, options={})
      req_options = { app_key: ENV['crm_key'],
                      filter: {
                          year: ref_date.year,
                          month: ref_date.month,
                          account_name: self.account_name
                      }
      }
      req_options.merge!({by_teacher: true}) if options[:by_teacher]
      if options[:filter]
        req_options[:filter].merge! options[:filter]
      end

      if options[:async]
        req_options[:async] = options[:async]
        req_options[:stat_name] = options[:stat_name]
        response = Typhoeus::Request.get("#{CRM_URL}/api/v0/enrollments/count", params: req_options)
        response.code == 202
      else
        response = Typhoeus::Request.get("#{CRM_URL}/api/v0/enrollments/count", params: req_options)
        parse_response(response,!options[:by_teacher])
      end
    end
  end

  private

  # @param response [Typhoeus::Response]
  # @param get_value [Boolean] (true)
  def parse_response(response,get_value=true)
    if response.success?
      body = ActiveSupport::JSON.decode response.body
      if get_value
        body['value']
      else
        body
      end
    else
      nil
    end
  end
end

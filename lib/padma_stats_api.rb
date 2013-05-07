# encoding: utf-8
# expects base class to have respond to account_name
module PadmaStatsApi

  CONTACTS_URL = case Rails.env
    when 'production'
     'https://padma-contacts.herokuapp.com'
    when 'staging'
     'https://padma-contacts-staging.herokuapp.com'
    else
      'http://localhost:3002'
  end

  CRM_URL = case Rails.env
    when 'production'
      'https://padma-crm.herokuapp.com'
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
    # @option options [Boolean] by_teacher
    # @return [Integer/Array<Hash>] will return array if :by_teacher option is given.
    def fetch_stat_from_crm(name,ref_date,options={})
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
        when :enrollments
          self.count_enrollments(ref_date,options)
        when :dropouts
          self.count_drop_outs(ref_date,options)
        when :demand
          self.count_communications(ref_date,options)
        when :interviews
          self.count_interviews(ref_date,options)
        when :p_interviews
          self.count_interviews(ref_date, options.merge({filter: { coefficient: 'p' }}))
        when :emails
          self.count_communications(ref_date, options.merge({filter: {media: 'email'}}))
        when :phonecalls
          self.count_communications(ref_date, options.merge({filter: { media: 'phone_call'}}))
      end
    end

    # Fetches students count from CRM-ws
    # @param ref_date [Date]
    # @param options [Hash]
    # @option options [String] level. Filter by level. Valid values: aspirante, sádhaka, yôgin, chêla, graduado, asistente, docente, maestro
    # @option options [String] teacher_username. -- will scope to this specific teacher
    # @option options [Boolean] by_teacher. -- will return all teachers -- If :teacher_username is given this will be ignored.
    # Returns array if by_teacher given.
    # @return [Integer/Array<Hash>]
    def count_students(ref_date, options = {})
      req_options = { app_key: ENV['crm_key'],
                      year: ref_date.year,
                      month: ref_date.month
                     }

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

      response = Typhoeus::Request.get("#{CRM_URL}/api/v0/accounts/#{self.account_name}/count_students", params: req_options)
      parse_response(response,!options[:by_teacher])
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

      response = Typhoeus::Request.get("#{CRM_URL}/api/v0/communications/count", params: req_options)
      parse_response(response)
    end

    def count_drop_outs(ref_date,options={})
      req_options = { app_key: ENV['crm_key'],
                      filter: {
                          year: ref_date.year,
                          month: ref_date.month,
                          account_name: self.account_name
                      }
      }
      req_options.merge!({by_teacher: true}) if options[:by_teacher]

      response = Typhoeus::Request.get("#{CRM_URL}/api/v0/drop_outs/count", params: req_options)
      parse_response(response,!options[:by_teacher])
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

      response = Typhoeus::Request.get("#{CRM_URL}/api/v0/enrollments/count", params: req_options)
      parse_response(response,!options[:by_teacher])
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

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
    # @option options :async (false) queue in hydra but don't run.
    # @option options :hydra (nil)
    def fetch_stat_from_crm(name,ref_date, options={})
      case name.to_sym
        when :students
          self.count_students(ref_date, options)
        when :aspirante_students
          self.count_students(ref_date, options.merge(level: 'aspirante'))
        when :sadhaka_students
          self.count_students(ref_date, options.merge(level: 'sádhaka'))
        when :yogin_students
          self.count_students(ref_date, options.merge(level: 'yôgin'))
        when :chela_students
          self.count_students(ref_date, options.merge(level: 'chêla'))
        when :graduado_students
          self.count_students(ref_date, options.merge(level: 'graduado'))
        when :assistant_students
          self.count_students(ref_date, options.merge(level: 'asistente'))
        when :professor_students
          self.count_students(ref_date, options.merge(level: 'docente'))
        when :master_students
          self.count_students(ref_date, options.merge(level: 'maestro'))
        when :enrollments
          self.count_enrollments(ref_date, options)
        when :dropouts
          self.count_drop_outs(ref_date, options)
        when :demand
          self.count_communications(ref_date, options)
        when :interviews
          self.count_interviews(ref_date, options)
        when :p_interviews
          self.count_interviews(ref_date, options.merge(filter: { coefficient: 'p' }))
        when :emails
          self.count_communications(ref_date, options.merge(filter: {media: 'email'}))
        when :phonecalls
          self.count_communications(ref_date, options.merge(filter: { media: 'phone_call'}))
      end
    end

    # Fetches students count from CRM-ws
    # @param ref_date [Date]
    # @param options [Hash]
    # @option options [String] level. Filter by level. Valid values: aspirante, sádhaka, yôgin, chêla, graduado, asistente, docente, maestro
    # @option options [String] teacher_username
    # @option options :async (false) queue in hydra but don't run.
    # @option options :hydra (nil)
    # @return [Integer]
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
      end

      request = Typhoeus::Request.new("#{CRM_URL}/api/v0/accounts/#{self.account_name}/count_students", params: req_options)
      request.on_complete do |response|
        if response.success?
          h = ActiveSupport::JSON.decode response.body
          h['value']
        else
          nil
        end
      end
      run_or_queue(options, request)
    end


    def count_interviews(ref_date, options={})
      options[:filter] ||= {}
      options[:filter].merge!({media: 'interview'})
      count_communications(ref_date,options)
    end

    def count_communications(ref_date,options={})
      req_options = { app_key: "844d8c2d20",
                      filter: {
                          year: ref_date.year,
                          month: ref_date.month,
                          account_name: self.account_name
                      }
      }
      if options[:filter]
        req_options[:filter].merge! options[:filter]
      end

      req = Typhoeus::Request.new("#{CRM_URL}/api/v0/communications/count", params: req_options)
      req.on_complete do |response|
        if response.success?
          h = ActiveSupport::JSON.decode response.body
          h['value']
        else
          nil
        end
      end
      run_or_queue options, req
    end

    def count_drop_outs(ref_date)
      req_options = { app_key: "844d8c2d20",
                      filter: {
                          year: ref_date.year,
                          month: ref_date.month,
                          account_name: self.account_name
                      }
      }

      req = Typhoeus::Request.new("#{CRM_URL}/api/v0/drop_outs/count", params: req_options)
      req.on_complete do |response|
      if response.success?
        h = ActiveSupport::JSON.decode response.body
        h['value']
      else
        nil
      end
      run_or_queue options, req
    end

    def count_enrollments(ref_date, options={})
      req_options = { app_key: "844d8c2d20",
                      filter: {
                          year: ref_date.year,
                          month: ref_date.month,
                          account_name: self.account_name
                      }
      }

      request = Typhoeus::Request.new("#{CRM_URL}/api/v0/enrollments/count", params: req_options)
      request.on_complete do |response|
        if response.success?
          h = ActiveSupport::JSON.decode response.body
          h['value']
        else
          nil
        end
      end
      run_or_queue(options,request)
    end

  end

  private

  ##
  # Will run or enqueue request according to options
  #
  # @param options [Hash]
  # @param request [Typhoeus::Request]
  #
  # @option options :hydra (nil)
  # @option options async (false)
  def run_or_queue(options, request)
    hydra = options[:hydra] || Typhoeus::Hydra.new
    hydra.queue(request)
    unless options[:async]
      hydra.run
    else
      hydra
    end
  end
end

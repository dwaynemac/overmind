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

    # Fetches students count from CRM-ws
    # @param ref_date [Date]
    # @param options [Hash] -- No options available yet
    # @option options [String] level. Filter by level. Valid values: aspirante, sádhaka, yôgin, chêla, graduado, asistente, docente, maestro
    # @return [Integer]
    def count_students(ref_date, options = {})
      req_options = { app_key: "844d8c2d20",
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

      response = Typhoeus::Request.get("#{CRM_URL}/api/v0/accounts/#{self.account_name}/count_students", params: req_options)
      if response.success?
        h = ActiveSupport::JSON.decode response.body
        h['value']
      else
        nil
      end
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

      response = Typhoeus::Request.get("#{CRM_URL}/api/v0/communications/count", params: req_options)
      if response.success?
        h = ActiveSupport::JSON.decode response.body
        h['value']
      else
        nil
      end
    end

    def count_drop_outs(ref_date)
      req_options = { app_key: "844d8c2d20",
                      filter: {
                          year: ref_date.year,
                          month: ref_date.month,
                          account_name: self.account_name
                      }
      }

      response = Typhoeus::Request.get("#{CRM_URL}/api/v0/drop_outs/count", params: req_options)
      if response.success?
        h = ActiveSupport::JSON.decode response.body
        h['value']
      else
        nil
      end
    end

    def count_enrollments(ref_date, options={})
      req_options = { app_key: "844d8c2d20",
                      filter: {
                          year: ref_date.year,
                          month: ref_date.month,
                          account_name: self.account_name
                      }
      }

      response = Typhoeus::Request.get("#{CRM_URL}/api/v0/enrollments/count", params: req_options)
      if response.success?
        h = ActiveSupport::JSON.decode response.body
        h['value']
      else
        nil
      end
    end

  end
end

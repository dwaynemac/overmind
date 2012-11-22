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

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  end

  module ClassMethods
  end

  module InstanceMethods

    # Fetches students count from Contacts-ws
    # @param ref_date [Date]
    # @param options [Hash]
    # @return [Integer]
    def count_students(ref_date, options = {})
      req_options = {name: 'students',
                      account_name: self.account_name,
                      year: ref_date.year,
                      month: ref_date.month
                     }

      response = Typhoeus::Request.get("#{CONTACTS_URL}/v0/contacts/calculate",req_options)
      if response.success?
        h = ActiveSupport::JSON.decode response.body
        h[:value]
      else
        nil
      end
    end

  end
end

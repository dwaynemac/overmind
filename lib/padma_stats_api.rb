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
      req_options = { app_key: "844d8c2d20a9cf9e97086df94f01e7bdd3d9afaa716055315706f2e31f40dc097c632af53e74ce3d5a1f23811b4e32e7a1e2b7fa5c128c8b28f1fc6e5a392015",
                      name: 'students',
                      account_name: self.account_name,
                      year: ref_date.year,
                      month: ref_date.month
                     }

      response = Typhoeus::Request.get("#{CONTACTS_URL}/v0/contacts/calculate",params: req_options)
      if response.success?
        h = ActiveSupport::JSON.decode response.body
        h['value']
      else
        nil
      end
    end

  end
end

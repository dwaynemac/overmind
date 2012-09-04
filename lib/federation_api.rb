# expects base class to respond to :nucleo_id
module FederationApi

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods

    base.send :validates_uniqueness_of, :nucleo_id
  end

  module ClassMethods
    def api
      RemoteFederation
    end


    def load_from_sv
      Federation.api.paginate.each do |federation|
        local_fed = Federation.find_by_nucleo_id(federation.id)
        if local_fed.nil?
          Federation.create! name: federation.name, nucleo_id: federation.id
        else
          if local_fed.name != federation.name
            local_fed.update_attribute :name, federation.name
          end
        end
      end
    end

  end

  module InstanceMethods

    def api
      self.nucleo_id.nil? ? nil : RemoteFederation.find(self.nucleo_id)
    end

    def testing
      puts "testing"
    end

  end
end

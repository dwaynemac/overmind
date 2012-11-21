# This module extends Nucleo API client methods into a Class
# Nucleo is Office's main DB.
# expects base class to respond to :nucleo_id
module SchoolApi

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods

    base.send :validates_uniqueness_of, :nucleo_id, allow_blank: true
  end

  module ClassMethods
    def api
      RemoteSchool
    end

    # Fetches enabled schools from SecretariaVirtual
    #  If school doesn't exist localy.
    #  * it's created
    #  If school exists localy
    #  * name is updated
    def load_from_sv
      Federation.load_from_sv
      schools = self.api.paginate(filter: 'enabled')
      schools.each do |school|
        local_school = School.find_by_nucleo_id(school.id)
        if local_school.nil?
          local_fed = Federation.find_by_nucleo_id(school.federation_id)
          School.create(name: school.name, nucleo_id: school.id, federation_id: local_fed.id)
        else
          new_attributes = {}

          if local_school.name != school.name
            new_attributes.merge!({name: school.name})
          end
          if local_school.federation.try(:nucleo_id) != school.federation_id
            new_fed = Federation.find_by_nucleo_id(school.federation_id)
            new_attributes.merge!({federation_id: new_fed.id})
          end

          unless new_attributes.empty?
            local_school.update_attributes new_attributes
          end
        end
      end
    end

  end

  module InstanceMethods

    def api
      self.nucleo_id.nil? ? nil : RemoteSchool.find(self.nucleo_id)
    end

  end
end

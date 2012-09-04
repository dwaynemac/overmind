# expects base class to respond to :nucleo_id
module SchoolApi

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods

    base.send :validates_uniqueness_of, :nucleo_id
  end

  module ClassMethods
    def api
      RemoteSchool
    end


    def load_from_sv
      Federation.load_from_sv
      schools = self.api.paginate(filter: 'enabled')
      schools.each do |school|
        local_school = School.find_by_nucleo_id(school.id)
        if local_school.nil?
          local_fed = Federation.find_by_nucleo_id(school.federation_id)
          School.create(name: school.name, nucleo_id: school.id, federation_id: local_fed.id)
        else
          if local_school.name != school.name
            local_school.update_attribute :name, school.name
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

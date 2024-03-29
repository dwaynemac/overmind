require 'appsignal'
require 'appsignal/integrations/object'

class SchoolMonthlyStat < MonthlyStat
  default_scope -> { where(teacher_id: nil) }
  # attr_protected :teacher_id

  validate :teacher_id_should_be_nil
  
  def self.stats_for_event(event)
    ret  = []

    if event =~ /interview/
      ret << :p_interviews
      ret << :male_p_interviews
      ret << :enrollment_rate
      ret << :male_enrollment_rate
      ret << :interviews
      ret << :male_interviews
      ret << :male_interviews_rate
      ret << :female_interviews
      ret << :female_interviews_rate
    end
    ret << :phonecalls if event =~ /phone_call/
    ret << :emails if event =~ /email/
    ret << :website_contact if event =~ /website_contact/
    ret << :messaging_comms if event =~ /messaging/
    ret << :social_comms if event =~ /social/
    
    if event =~ /communication/
      ret << :demand
      ret << :male_demand
      ret << :male_demand_rate
      ret << :female_demand
      ret << :female_demand_rate
      ret << :conversion_count
      ret << :conversion_rate
    end

    ret
  end

  # If stat exists in DB it will recalculate its value.
  # If it doesnt exist it will calculate value and store it
  # @param school
  # @param name
  # @param ref_date
  # @param options
  # @option async
  def self.sync_from_service!(school,name,ref_date, options = {})
    if options[:async]
      ms = SchoolMonthlyStat.new(school: school, name: name, ref_date: ref_date)
      if ms.set_service == "crm"
        ms.ping_service_for_resync
      end
    else
      ms = school.school_monthly_stats.where(name: name, ref_date: ref_date)
      if ms.blank?
        create_from_service!(school,name,ref_date)
      else
        st = ms.first
        st.update_from_service!
      end
    end
  end

  # creates a new MonthlyStat fetching value from remote service.
  # @param [School] school
  # @param [String] name. Statistic code name
  # @param [Date] ref_date
  # @example @school.monthly_stats.create_from_service!(:enrollments, Date.today)
  # @raise exception if creation fails
  # @return [MonthlyStat/NilClass]
  def self.create_from_service!(school,name,ref_date)
    ms = school.school_monthly_stats.new(name: name, ref_date: ref_date)
    ms.set_service
    remote_value = ms.get_remote_value

    if remote_value
      ms.value = remote_value
    end

    ms.save ? ms : nil
  end
  appsignal_instrument_class_method :create_from_service!

  # updates value
  # @return [Integer] new value
  def update_from_service!
    unless service.blank?
      remote_value = get_remote_value
      if remote_value && remote_value.to_i != self.value.to_i
        self.update_attributes value: remote_value
      else
        nil
      end
    end
  end
  appsignal_instrument_method :update_from_service!

  def ping_service_for_resync
    if service == "crm"
      school.fetch_stat_from_crm(name, ref_date, async: true)
    else
      nil
    end
  end

  def queue_resync
    if service == "crm"
      unless Delayed::Job.where("handler like '%SchoolMonthlyStat%id: #{id}%ping_service_for_resync%' AND attempts = 0").exists?
        delay.ping_service_for_resync
      end
    else
      unless Delayed::Job.where("handler like '%SchoolMonthlyStat%id: #{id}%update_from_service!%' AND attempts = 0").exists?
        delay.update_from_service!
      end
    end

  end

  # Will delegate fetching value to a corresponding module according to
  # service.
  # @return [Integer/Array<Hash>]
  def get_remote_value
    return nil if service.blank?
    case service
      when 'kshema'
        school.fetch_stat(self.name,ref_date)
      when 'crm'
        school.fetch_stat_from_crm(self.name,ref_date)
      when 'overmind'
        ls = LocalStat.new(name: self.name, ref_date: ref_date, school: school)
        ls.value
      else
        raise "Unknown service : #{service}"
    end
  end
  appsignal_instrument_method :get_remote_value

  private

  def teacher_id_should_be_nil
    unless teacher_id.nil?
      errors.add :teacher_id, 'should be nil'
    end
  end
end

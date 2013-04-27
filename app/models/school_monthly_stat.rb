class SchoolMonthlyStat < MonthlyStat
  default_scope where(teacher_id: nil)
  attr_protected :teacher_id

  validates_uniqueness_of :name, scope: [:school_id, :ref_date]
  validate :teacher_id_should_be_nil

  # creates a new MonthlyStat fetching value from remote service.
  # @param [School] school
  # @param [String] name. Statistic code name
  # @param [Date] ref_date
  # @example @school.monthly_stats.create_from_service!(:enrollments, Date.today)
  # @raise exception if creation fails
  # @return [MonthlyStat/NilClass]
  def self.create_from_service!(school,name,ref_date)
    ms = school.monthly_stats.new(name: name, ref_date: ref_date)
    ms.set_service
    remote_value = ms.get_remote_value

    if remote_value
      ms.value = remote_value
    end

    ms.save ? ms : nil
  end

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

  private

  def teacher_id_should_be_nil
    unless teacher_id.nil?
      errors.add :teacher_id, 'should be nil'
    end
  end
end

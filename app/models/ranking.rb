class Ranking

  extend  ActiveModel::Naming
  extend  ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion

  DEFAULT_COLUMN_NAMES = [:students, :enrollment_rate, :dropout_rate, :male_students_rate, :students_average_age] 
  VALID_COLUMNS = MonthlyStat::VALID_NAMES

  COLUMNS_FOR_VIEW = [
   [:students, :enrollments, :dropouts],
   [:enrollment_rate, :dropout_rate],
   [:dropouts_begginers, :dropouts_intermediates, :begginers_dropout_rate, :swasthya_dropout_rate],
   [:male_students, :female_students, :male_students_rate],
   [:students_average_age],
   [:aspirante_students, :sadhaka_students, :yogin_students,
    :chela_students, :graduado_students, :assistant_students,
    :professor_students, :master_students],
   [:aspirante_students_rate,
    :sadhaka_students_rate,
    :yogin_students_rate,
    :chela_students_rate
   ],
   [:demand,
    :male_demand, :female_demand,
    :male_demand_rate, :female_demand_rate,
    :interviews,
    :male_interviews, :female_interviews,
    :male_p_interviews,
    :male_interviews_rate, :female_interviews_rate,
    :p_interviews, :emails, :phonecalls, :website_contact, :messaging_comms, :social_comms],
   [:conversion_rate, :conversion_count]
  ]

  attr_accessor :federation_ids,
                :column_names,
                :ref_since,
                :ref_until

  validate :valid_date_period

  def initialize(attributes=nil)
    attributes = {} if attributes.nil?

    set_dates(attributes)
    set_federation_ids(attributes)
    set_column_names(attributes)
    
  end

  def matrix
    @matrix ||= RankingMatrix.new(stats).matrix
  end

  def stats
    if @stats
      @stats
    else
      pre_scope = SchoolMonthlyStat.select([:name, :value, :school_id])
                                   .includes(:school)
                                   .where("(schools.cached_nucleo_enabled IS NULL) OR schools.cached_nucleo_enabled")
                                   .where(ref_date: (ref_since.to_date..ref_until.to_date))
      pre_scope = pre_scope.where(schools: { federation_id: @federation_ids}) unless @federation_ids.nil?
      simple_reduction_scope = pre_scope.where(name: @column_names - columns_with_special_reduction)
  
      @stats = simple_reduction_scope.all.group_by(&:school).map do |school, stats|
        stats_by_name = stats.group_by(&:name)
        (stats_by_name.keys + columns_with_special_reduction).map do |name|
          ReducedStat.new(school: school,
                          stats: stats_by_name[name],
                          stats_scope: pre_scope.where(school_id: school.id), # for stats with special reduction. 
                          name: name,
                          reduce_as: :avg
                          )
        end
      end.flatten
    end
  end

  def school_ids
    @school_ids ||= stats.map(&:school_id).uniq
  end

  def persisted?
    false
  end
  
  def columns_with_special_reduction
    @column_names.select do |name|
      LocalStat.has_special_reduction?(name)
    end.map(&:to_s)
  end

  private

  def valid_date_period
    if self.ref_since && self.ref_until <= self.ref_since
      errors.add(:ref_until, t('ranking.validations.ref_until'))
    end
  end

  def set_dates(attributes)
    [:ref_since, :ref_until].each do |ref|
      val = if attributes[ref]
        attributes[ref]
      elsif attributes["#{ref}(1i)"] && attributes["#{ref}(2i)"]
        Date.new(attributes["#{ref}(1i)"].to_i,
                 attributes["#{ref}(2i)"].to_i,
                 1).end_of_month
      end
      self.send("#{ref}=", val)
    end

    # defaults
    self.ref_since = Date.today.end_of_month if self.ref_since.nil?
    self.ref_until = Date.today.end_of_month if self.ref_until.nil?
  end

  def set_federation_ids(attributes)
    @federation_ids = attributes.fetch(:federation_ids , Federation.pluck(:id)).reject(&:blank?)
    if @federation_ids.first.is_a?(String)
      @federation_ids = @federation_ids.map(&:to_i)
    end
  end

  def set_column_names(attributes)
    @column_names = attributes.fetch( :column_names , DEFAULT_COLUMN_NAMES).reject(&:blank?)
    if @column_names.first.is_a?(String)
      @column_names = @column_names.map(&:to_sym)
    end
  end
end

class Ranking

  extend  ActiveModel::Naming
  extend  ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion

  DEFAULT_COLUMN_NAMES = [:students, :enrollment_rate, :dropout_rate, :male_students_rate] 
  VALID_COLUMNS = MonthlyStat::VALID_NAMES

  COLUMNS_FOR_VIEW = [
   [:students, :enrollments, :dropouts],
   [:enrollment_rate, :dropout_rate],
   [:dropouts_begginers, :dropouts_intermediates, :begginers_dropout_rate, :swasthya_dropout_rate],
   [:male_students, :female_students, :male_students_rate],
   [:aspirante_students, :sadhaka_students, :yogin_students,
    :chela_students, :graduado_students, :assistantxe_students,
    :professor_students, :master_students],
   [:aspirante_students_rate,
    :sadhaka_students_rate,
    :yogin_students_rate,
    :chela_students_rate
   ],
   [:demand, :interviews, :p_interviews, :emails, :phonecalls, :website_contact],
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
    scope = SchoolMonthlyStat.select([:name, :value, :school_id])
                             .includes(:school)
                             .where(ref_date: (ref_since.to_date..ref_until.to_date))
                             .where(name: @column_names)
    scope = scope.where(schools: { federation_id: @federation_ids}) unless @federation_ids.nil?

    scope.all.group_by(&:school).map do |school, stats|
      stats.group_by(&:name).map do |name, stats|
        ReducedStat.new(school: school, stats: stats, name: name, reduce_as: :avg)
      end
    end.flatten
  end

  def school_ids
    @school_ids ||= stats.map(&:school_id)
  end

  def persisted?
    false
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
    self.ref_since = 1.year.ago.end_of_month.to_date if self.ref_since.nil?
    self.ref_until = 1.month.ago.end_of_month.to_date if self.ref_until.nil?
  end

  def set_federation_ids(attributes)
    @federation_ids = attributes.fetch(:federation_ids , Federation.pluck(:id))
    if @federation_ids.first.is_a?(String)
      @federation_ids = @federation_ids.map(&:to_i)
    end
  end

  def set_column_names(attributes)
    @column_names = attributes.fetch( :column_names , DEFAULT_COLUMN_NAMES)
    if @column_names.first.is_a?(String)
      @column_names = @column_names.map(&:to_sym)
    end
  end
end

class Ranking

  extend  ActiveModel::Naming
  extend  ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion

  DEFAULT_COLUMN_NAMES = [:students, :enrollments, :dropouts, :demand, :interviews] 
  VALID_COLUMNS = MonthlyStat::VALID_NAMES

  attr_accessor :federation_ids,
                :column_names

  def initialize(attributes)
    attributes = {} if attributes.nil?
    @date = attributes.fetch( :date , nil)

    @federation_ids = attributes.fetch(:federation_ids , Federation.pluck(:id))
    if @federation_ids.first.is_a?(String)
      @federation_ids = @federation_ids.map(&:to_i)
    end

    @column_names = attributes.fetch( :column_names , DEFAULT_COLUMN_NAMES)
    if @column_names.first.is_a?(String)
      @column_names = @column_names.map(&:to_sym)
    end
  end

  def matrix
    @matrix ||= RankingMatrix.new(stats).matrix
  end

  def stats
    unless @stats
      scope = SchoolMonthlyStat.select([:name, :value, :school_id]).includes(:school).where(ref_date: date)
      scope = scope.where(name: @column_names)
      scope = scope.where(schools: { federation_id: @federation_ids}) unless @federation_ids.nil?
      @stats = scope
    end
    @stats
  end

  def school_ids
    @school_ids ||= stats.map(&:school_id)
  end

  def date
    if @date.nil?
      1.month.ago.end_of_month.to_date
    else
      Date.new(@date[:year].to_i, @date[:month].to_i, 1).end_of_month
    end
  end

  # ================
  #

  def persisted?
    false
  end
end

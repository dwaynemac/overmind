class Ranking

  DEFAULT_COLUMN_NAMES = ['students', 'enrollments', 'dropouts', 'demand', 'interviews'] 

  attr_accessor :filters, :column_names

  def initialize(attributes)
    attributes = {} if attributes.nil?
    @date = attributes.fetch( :date , nil)
    @filters = attributes.fetch( :filters , nil)
    @column_names = attributes.fetch( :column_names , DEFAULT_COLUMN_NAMES)
  end

  def matrix
    @matrix ||= RankingMatrix.new(stats).matrix
  end

  def stats
    unless @stats
      scope = SchoolMonthlyStat.select([:name, :value, :school_id]).includes(:school).where(ref_date: date)
      scope = scope.where(name: @column_names)
      scope = scope.where(schools: @filters) unless @filters.nil?
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
end

class Matrixer

  # @param [ActiveRecord::Relation]
  def initialize(stat)
    @stats = stat
  end
  
  # Generates a matrix from current scope with
  #   stats names as it's root indexes,
  #   months number as 1st level indexes and
  #   values in a 3rd level.
  #
  # @example @school.school_monthly_stats.where(year: 2013).to_matrix
  # @return [Hash]
  def to_matrix
    matrix = Hash.new({})

    # fetch from DB grouped by name.
    @stats.scoped.group_by(&:name).each_pair do |stat_name, stats|
      # WARNING if stat has not been scoped to a year this will acumulate all months
      matrix[stat_name] = stats.group_by{|ms|ms.ref_date.month}
    end

    # reduce each month to a total
    matrix.each_pair do |stat_name,stats_by_month|
      stats_by_month.each_pair do |month,stats|
        if stats.size>1
          val = stats.sum(&:value)
          if MonthlyStat.is_a_rate?(stat_name)
            val = val.to_f/stats.size
          end

          matrix[stat_name][month] = ReducedStat.new(
              value: val,
              ref_date: stats.last.ref_date
          )
        else
          matrix[stat_name][month] = stats.first
        end
      end
    end

    matrix.symbolize_keys!

    matrix = add_enrollment_rate(matrix)
    matrix = add_dropout_rate(matrix)
    add_swasthya_students_subtotal(matrix)
  end

  private

  # @param matrix [Hash]
  # @return [Hash] matrix with enrollment_rate added.
  def add_enrollment_rate(matrix)
    matrix[:enrollment_rate] = {}
    matrix[:enrollments].each_key do |month|
      interviews = matrix[:p_interviews][month].try(:value)
      if interviews && interviews > 0
        enrollments = matrix[:enrollments][month].try(:value) || 0
        matrix[:enrollment_rate][month] = ReducedStat.new(value: enrollments.to_f / interviews.to_f)
      end
    end
    matrix
  end

  # @param matrix [Hash]
  # @return [Ha6sh] matrix with dropout_rate added
  def add_dropout_rate(matrix)
    matrix[:dropout_rate] = {}
    matrix[:dropouts].each_pair do |month,stat|
      students = nil
      if month > 1
        students = matrix[:students][month-1].try(:value)
      else
        # reproduce current scope removing conditions on ref_date
        students = @stats.unscoped.joins(@stats.scoped.joins_values).where(@stats.scoped.where_clauses.reject{|c|c=~/ref_date/}).where(ref_date: (stat.ref_date-1.month), name: 'students').sum(:value)
      end

      if students && students > 0
        drops = matrix[:dropouts][month].try(:value) || 0
        matrix[:dropout_rate][month] = ReducedStat.new(value: drops.to_f / students.to_f)
      end
    end
    matrix
  end

  # Adds sum of students in swasthya
  # @param matrix [Hash]
  # @return [Hash] matrix with swasthya_students_subtotal added
  def add_swasthya_students_subtotal(matrix)
    matrix[:swasthya_students_subtotal] = {}
    stats = [:sadhaka_students,
             :yogin_students,
             :chela_students,
             :graduado_students,
             :assistant_students,
             :professor_students,
             :master_students]
    (1..12).each do |month|
      unless stats.select{|s|matrix[s][month]}.empty?
        val = stats.map{|stat| matrix[stat][month].try(:value) || 0 }.sum
        matrix[:swasthya_students_subtotal][month] = ReducedStat.new(value: val)
      end
    end
    matrix
  end

end
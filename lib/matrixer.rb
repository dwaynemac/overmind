# Matrixer
#
# This class creates a matrix for easily navigate through stats
# in the view and render the table
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
    @stats.group_by(&:name).each_pair do |stat_name, stats|
      # WARNING if stat has not been scoped to a year this will acumulate all months
      matrix[stat_name] = stats.group_by{|ms|ms.ref_date.month}
    end

    # reduce each month to a total
    matrix.each_pair do |stat_name,stats_by_month|
      red_fn = if MonthlyStat.is_a_rate?(stat_name) || stat_name == 'students_average_age'
        :avg
      else
        :sum
      end

      stats_by_month.each_pair do |month,stats|
        rs = nil
        if stats.size>1
          if LocalStat.has_special_reduction?(stat_name)
            # ignore this values, for reduction we need to recalculate from source. 
            stat_scope = @stats.all
                               .where(ref_date: stats.first.ref_date)
            rs = ReducedStat.new(
                            name: stat_name,
                            value: LocalStat.new().send("reduce_#{stat_name}",
                                                        stat_scope )
                            )
          else
             
            rs = ReducedStat.new(
              stats: stats,
              reduce_as: red_fn
            )
          
            rs.value # calculate and cache value
          end

          matrix[stat_name][month] = rs
        else
          matrix[stat_name][month] = stats.first
        end
      end

      if subtotal_for?(stat_name)
        matrix[stat_name][:total] = ReducedStat.new(
          name: stat_name,
          stats: matrix[stat_name].values,
          stats_scope: @stats,
          reduce_as: red_fn
        )
      end

    end

    matrix.symbolize_keys!

    #matrix = add_dropout_rate(matrix)
    add_swasthya_students_subtotal(matrix)
  end

  private
  
  def subtotal_for?(stat_name)
    ignore_students = !((stat_name =~ /student/) || stat_name.in?(%W(in_professional_training)))
    ignore_rates_wout_special_reductions = !(stat_name =~ /rate/ && !LocalStat.has_special_reduction?(stat_name))
    true && ignore_students && ignore_rates_wout_special_reductions
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

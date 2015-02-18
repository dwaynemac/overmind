module MonthlyStatsHelper

  def print_value(monthly_stat)
    v = monthly_stat.try :value
    return '' if v.nil?
    if !monthly_stat.is_a?(ReducedStat) && monthly_stat.is_a_rate?
      # rates are represented as 'cents' in integer.
      "#{number_with_precision(v.to_f/100, precision: 2)}%"
    else
      v
    end
  end

  def can_sync_update?(stat)
    if stat.is_a?(TeacherMonthlyStat)
      LocalStat.is_local_stat?(stat.name)
    else
      stat.service.present?
    end
  end
  
  # @option options [String] stat_name
  # @return [Boolean]
  def can_sync_create?(options={})
    is_local_stat = LocalStat.is_local_stat?(options[:stat_name])
    not_teacher_stats = !options[:teacher_stats]
    month_past = (options[:ref_date].end_of_month < Date.today)
    is_local_stat && not_teacher_stats && month_past
  end

  # @param options [Hash]
  # @option options [MonthlyStat] monthly_stat
  # @option options [String] stat_name
  # @option options [Date] ref_date
  # @option options [Boolean] teacher_stats
  # @return [Boolean]
  def in_place_create?(options={})
    permitions = current_ability.can?(:create,MonthlyStat)
    month_past = (options[:ref_date].end_of_month < Date.today)
    not_teacher_stats = !options[:teacher_stats]
    is_not_local_stat   = !LocalStat.is_local_stat?(options[:stat_name])

    permitions && month_past && not_teacher_stats && is_not_local_stat
  end

  # @param options [Hash]
  # @option options [MonthlyStat] monthly_stat
  # @option options [Date] ref_date
  # @option options [Boolean] teacher_stats
  # @return [Boolean]
  def in_place_edit?(options={})
    permitions = current_ability.can?(:update,MonthlyStat)
    service_blank = options[:monthly_stat].service.blank?
    month_past = (options[:ref_date].end_of_month < Date.today)
    is_not_reduced_stat = !options[:monthly_stat].is_a?(ReducedStat)
    is_not_local_stat   = !LocalStat.is_local_stat?(options[:monthly_stat].name)
    not_teacher_stats = !options[:teacher_stats]

    permitions && service_blank && month_past && is_not_reduced_stat && not_teacher_stats && is_not_local_stat
  end

end

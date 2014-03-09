module MonthlyStatsHelper

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

module MonthlyStatsHelper

  def print_value_with_link(monthly_stat)
    if monthly_stat.url_to_crm_list.nil? || monthly_stat.account_name != current_user.padma.current_account_name
      print_value(monthly_stat)
    else
      link_to print_value(monthly_stat), monthly_stat.url_to_crm_list, target: '_blank'
    end
  end
  
  def print_value(monthly_stat, options = {})
    v = monthly_stat.try :value
    return '' if v.nil?
    if monthly_stat.is_a_rate?
      # rates are represented as 'cents' in integer.
      sufix = options[:sufix] || "%"
      "#{number_with_precision(v.to_f/100, precision: 2)}#{sufix}"
    elsif monthly_stat.is_a?(ReducedStat) && (monthly_stat.reduce_as.to_sym == :avg)
      number_with_precision(v, precision: 0)
    else
      v
    end
  end

  def can_sync_month?(month)
   can?(:create, SyncRequest) && @school.padma_enabled? && Date.civil(@year.to_i,month.to_i,1).end_of_month <= Time.zone.today.to_date.end_of_month if @school && @year
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

  def can_delete?(options={})
    permitions = current_ability.can?(:destroy,MonthlyStat)
    service_blank = options[:monthly_stat].service.blank?
    month_past = (options[:ref_date].end_of_month < Date.today)
    is_not_reduced_stat = !options[:monthly_stat].is_a?(ReducedStat)
    is_not_local_stat   = !LocalStat.is_local_stat?(options[:monthly_stat].name)
    not_teacher_stats = !options[:teacher_stats]

    permitions && month_past && is_not_reduced_stat && not_teacher_stats && is_not_local_stat
  end

end

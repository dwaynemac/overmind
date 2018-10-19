module SchoolsHelper

  def print_year_subtotal_with_link(options={})
    reduced_stat = options[:reduced_stat]
    if reduced_stat
      if reduced_stat.name.in?(%W(enrollments male_enrollments dropouts p_interviews male_p_interviews))
        query = MonthlyStat.new().send("#{reduced_stat.name}_query",{
          l_limit: Date.civil(options[:year],1,1),
          r_limit: Date.civil(options[:year],12,31)
        })
        link_to print_value(reduced_stat), "#{APP_CONFIG['crm-url']}/contacts?#{query}", target: "_blank"
      else
        print_value(reduced_stat)
      end
    end
  end

  def data_freshness_label(school)
    label_class = if school.synced_at.nil? || school.synced_at < 1.month.ago
    #synced more than 1 month ago
        'danger'
    elsif school.synced_at < 1.week.ago
    #synced more than 1 week ago
      'warning'
    elsif school.synced_at.month != Time.zone.today.month
    # synced less than 1 week ago, but not current month
      'warning'
    else
      'success'
    end
    msg = school.synced_at.nil?? t('schools.never_synced') : "#{t('schools.index.synced_at')} #{l(@school.synced_at, format: :short)}"
    %[<span class="label label-#{label_class}">#{msg}</span>].html_safe
  end
end

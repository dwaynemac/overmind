module SchoolsHelper

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

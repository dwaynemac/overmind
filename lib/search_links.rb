module SearchLinks
  
  def url_to_crm_list
    if type == 'SchoolMonthlyStat'
      query = case name
      when 'demand'
        demand_query
      end
      
      if query.nil?
        nil
      else
        "#{APP_CONFIG['crm-url']}/contacts?#{query}"
      end
    end
  end
  
  private
  
  def demand_query
    q =  "contact_search[communication_period_start(1i)]=#{ref_date.year}"
    q += "&contact_search[communication_period_start(2i)]=#{ref_date.month}"
    q += "&contact_search[communication_period_start(3i)]=1"
    q += "&contact_search[communication_period_end(1i)]=#{ref_date.year}"
    q += "&contact_search[communication_period_end(2i)]=#{ref_date.month}"
    q += "&contact_search[communication_period_end(3i)]=#{ref_date.end_of_month.day}"
    q += "&contact_search[communication_direction]=incoming"
  end
end
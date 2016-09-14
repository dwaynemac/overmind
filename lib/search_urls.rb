module SearchUrls
  
  def url_to_crm_list
    if type == 'SchoolMonthlyStat'
      
      query = if respond_to?("#{name}_query")
        send("#{name}_query")
      else
        nil
      end
      
      if query.nil?
        nil
      else
        "#{APP_CONFIG['crm-url']}/contacts?#{query}"
      end
    end
  end
  
  def students_query
    date_eq('student_on',ref_date)
  end
  
  def male_students_query
    students_query + eq(:gender,:male)
  end
  
  def female_students_query
    students_query + eq(:gender,:female)
  end
  
  def enrollments_query
    q = date_eq("enrollment_period_start",ref_date.beginning_of_month,"")
    q += date_eq("enrollment_period_end",ref_date.end_of_month)
  end
  
  def dropouts_query
    q = date_eq("dropout_period_start",ref_date.beginning_of_month,"")
    q += date_eq("dropout_period_end",ref_date.end_of_month)
  end
  
  def demand_query
    q = "scope=global" # to include unlinked contacts
    q += date_eq("communication_period_start",ref_date.beginning_of_month)
    q += date_eq("communication_period_end",ref_date.end_of_month)
    q += eq('communication_direction','incoming')
  end
  
  def male_demand_query
    demand_query + eq(:gender,:male)
  end
  
  def female_demand_query
    demand_query + eq(:gender,:female)
  end
  
  private
  
  def eq(attribute,value,prefix="&")
    "#{prefix}contact_search[#{attribute}]=#{value}"
  end
  
  def date_eq(date_attribute,date,prefix="&")
    eq("#{date_attribute}(1i)",date.year,prefix) + eq("#{date_attribute}(2i)",date.month) + eq("#{date_attribute}(3i)",date.day)
  end
end
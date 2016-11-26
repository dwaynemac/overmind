module SearchUrls
  
  QUERIES_THAT_SUPPORT_TEACHER_FILTER = %W(p_interviews_query)
  def url_to_crm_list
    query = if type == 'SchoolMonthlyStat'
      
      if respond_to?("#{name}_query")
        send("#{name}_query")
      else
        nil
      end
      
    elsif type == "TeacherMonthlyStat"
      query_name = "#{name}_query"
      if query_name.in?(QUERIES_THAT_SUPPORT_TEACHER_FILTER)
        if respond_to?("#{name}_query")
          send("#{name}_query")
        else
          nil
        end
      else
        nil
      end
    end
    
    if query.nil?
      nil
    else
      "#{APP_CONFIG['crm-url']}/contacts?#{query}"
    end
  end
  
  def p_interviews_query
    ret = interviews_query + any_of(:communication_estimated_coefficient,[:pmenos,:perfil,:pmas])
    if type == "TeacherMonthlyStat"
      ret += any_of(:visit_usernames,[teacher_username])
    end
    ret
  end
  
  %W(email interview).each do |media|
    define_method "#{media}s_query" do
      demand_query + eq(:communication_media, media)
    end
  end
  
  def phonecalls_query
    demand_query + eq(:communication_media, :phone_call)
  end
  
  def website_contact_query
    demand_query + eq(:communication_media, :website_contact)
  end
  
  def male_interviews_query
    interviews_query + eq(:gender,:male)
  end
  
  def female_interviews_query
    interviews_query + eq(:gender,:female)
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
    # global scope disabled because of timeout in contacts-ws, reenable when solverd
    # q = "scope=global" # to include unlinked contacts
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
  
  def any_of(attribute,values,prefix="&")
    ret = "#{prefix}contact_search[#{attribute}][]=#{values.first}"
    values[1..values.length].each do |v|
      ret += "&contact_search[#{attribute}][]=#{v}"
    end
    ret
  end
  
  def eq(attribute,value,prefix="&")
    "#{prefix}contact_search[#{attribute}]=#{value}"
  end
  
  def date_eq(date_attribute,date,prefix="&")
    eq("#{date_attribute}(1i)",date.year,prefix) + eq("#{date_attribute}(2i)",date.month) + eq("#{date_attribute}(3i)",date.day)
  end
end
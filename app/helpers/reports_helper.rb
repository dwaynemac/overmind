module ReportsHelper
  def set_growth_rate growth
    growth < 0 ? growth : "+"+growth.to_s
  end  

  def pedagogic_chart_data
    chart_data = {  
                    'begginear'=> @begginers,
                    'sadhakas'=> @sadhakas,
                    'yogins'=> @yogins,
                    'chelas'=> @chelas,
                    'graduate'=> @graduados,
                    'assistant'=> @assistants,
                    'professor'=> @professors,

                  }
    chart_data.to_json.html_safe
  end

  def distribution_pie_chart_data
    pie_chart_data = {
                        "male_students"=> @male_students,
                        "female_students"=> @female_students
                     }
    pie_chart_data.to_json.html_safe
  end

  def students_pie_chart_data
    pie_chart_data = {
                        "begginer"=>@begginer,
                        "graduate"=>@graduate,
                        "senior"=>@senior
                     }
    pie_chart_data.to_json.html_safe                 
  end

  def set_current_month_and_year
    Date.today.strftime("%b %y")
  end    
end

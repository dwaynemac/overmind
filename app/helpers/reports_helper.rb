# encoding: utf-8
module ReportsHelper

  def pedagogic_snapshot_cache_key(year,month)
    [@school.synced_at,I18n.locale,year,month,'pedagogic_snapshot']
  end

  def not_upto_date
    unless @school.synced_at.nil?
      if @ref_date == Date.today.end_of_month
        @school.synced_at < Time.now-1.hour
      else
        @school.synced_at.to_date < @ref_date
      end
    end
  end

  def sync_button
    unless can?(:create, SyncRequest) && @school.padma_enabled? && not_upto_date
      %[<a href="#{refresh_school_reports_path(year: @year, month: @month, return_to: action_name)}" class="btn btn-secondary btn-sm" id="sync-arrow"><span class='glyphicon glyphicon-refresh'></span></a>].html_safe
          
    end
  end

  def set_growth_rate growth
    growth < 0 ? growth : "+"+growth.to_s
  end  

  def pedagogic_chart_labels
    chart_labels = {
                    'begginear'=> t('monthly_snapshot.pedagogic.chart_labels.begginer'),
                    'sadhakas'=> 'sádhakas',
                    'yogins'=> 'yôgins',
                    'chelas'=> 'chêlas',
                    'graduate'=> t('monthly_snapshot.pedagogic.chart_labels.graduate'),
                    'assistant'=> t('monthly_snapshot.pedagogic.chart_labels.assistante'),
                    'professor'=> t('monthly_snapshot.pedagogic.chart_labels.proffesor'),
    }
    chart_labels.to_json.html_safe
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
    DateTime.new(params[:year].to_i, params[:month].to_i ,1).strftime("%b %y")
  end

  def set_prev_month_url
    current_year = params[:year].to_i
    current_month = params[:month].to_i
    if current_month == 1
      prev_month = 12
      prev_year = current_year - 1
    else
      prev_month = current_month - 1
      prev_year = current_year  
    end    
    "/schools/#{params[:school_id]}/reports/#{current_report}/#{prev_year}/#{prev_month}"
  end

  def set_next_month_url
    current_year = params[:year].to_i
    current_month = params[:month].to_i
    if current_month == 12
      next_month = 1
      next_year = current_year + 1
    else
      next_month = current_month + 1
      next_year = current_year  
    end
    "/schools/#{params[:school_id]}/reports/#{current_report}/#{next_year}/#{next_month}"
  end

  def current_report
    if params[:action] == "marketing_snapshot"
      "marketing"
    elsif params[:action] == "pedagogic_snapshot"  
      "pedagogic"
    end    
  end  
end

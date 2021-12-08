class TeachersController < ApplicationController

  load_and_authorize_resource except: :show

  def show
    @school = School.find(params[:school_id])
    authorize! :read, @school
    @teacher = Teacher.find params[:id]

    @years = (2010..Date.today.year)
    @year = params[:year] || Date.today.year

    current_school_teachers = @school.account.present?? @school.account.users.map(&:username) : nil
    @teachers = current_school_teachers.blank?? @school.teachers : @school.teachers.select{|t| t.username.in?(current_school_teachers) }

    stats_scope = @school.teacher_monthly_stats.for_year(@year).where(teacher_id: params[:id])
    @stats = Matrixer.new(stats_scope).to_matrix

    @stat_names = get_stat_names.map(&:to_sym)

    queue_stats_resyncs

    respond_to do |format|
      format.html
      format.csv do
        response.headers['Content-Disposition'] = "attachment; filename='teacher_#{@teacher.id}_#{@year}.csv'"
        render 'show.csv.erb'
      end
    end
  end

  private

  def queue_stats_resyncs
    if ENV["queue_sync_on_show"] == "true"
      @stats.each do |stat_name, by_month|
        by_month.each do |month_number, values|
          next if month_number==:total
          ref_date = Date.civil(@year.to_i, month_number.to_i, 1).end_of_month
          service = MonthlyStat.service_for(@school, stat_name, ref_date)
          if service == "crm"
            unless Delayed::Job.where("handler like '%School\n  raw_attributes:\n    id:%#{@school.id}%fetch_stat_from_crm%#{stat_name}%#{ref_date.to_s}%by_teacher%'").exists?
              @school.delay.fetch_stat_from_crm(stat_name, ref_date, async: true, by_teacher: true)
            end
          end
        end
      end
    end
  end

  def get_stat_names
    regular = if params[:ranking] && params[:ranking][:column_names]
      cookies[:anual_report_stats] = params[:ranking][:column_names].reject(&:blank?)
    else
      # default
      if cookies[:anual_report_stats]
        cookies[:anual_report_stats].split("&")
      else
        %W(students dropouts dropout_rate demand conversion_rate p_interviews enrollments enrollment_rate )
      end
    end
    regular + MonthlyStat::MANUAL_STATS
  end
end

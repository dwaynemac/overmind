class RankingsController < ApplicationController
  
  def history
    authorize! :history, Ranking
    
    @federations = Federation.scoped 
    federation_ids = Federation.accessible_by(current_ability).pluck(:id)
    
    if params[:ranking].nil?
      if params[:federation_id]
        # we'r linking to a specific federation's list
        federation_ids = [params[:federation_id].to_i]
      end
      params[:ranking] = {
        federation_ids: federation_ids,
        column_names: [:students],
        ref_since: 2.years.ago.to_date
      }
    else
      params[:ranking][:column_names] = [params[:ranking][:column_names]]
    end
    @ranking = Ranking.new params[:ranking]
    
    
    @ref_dates = []
    @stats_hash = {}
    
    stats_scope = SchoolMonthlyStat.where(name: @ranking.column_names.first)
                     .where("ref_date >= ?", @ranking.ref_since)
                     .where("ref_date <= ?", @ranking.ref_until)
                     .joins(:school)
                     .where(schools: { federation_id: @ranking.federation_ids })
                     
    school_ids = stats_scope.pluck(:school_id).uniq
    @schools = School.find school_ids
    
    stats_scope.each do |stat|
      @ref_dates << stat.ref_date
      @stats_hash[stat.ref_date] = {} if @stats_hash[stat.ref_date].nil?
      @stats_hash[stat.ref_date][stat.school_id] = stat.value
    end
    
    @ref_dates.uniq!.sort!
    
    respond_to do |format|
      format.html
      format.csv do
        response.headers['Content-Disposition'] = "attachment; filename=history.csv"
        render 'history.csv.erb'
      end 
    end
  end
  
  def students
    authorize! :see_global, MonthlyStat
    
    @ref_dates = []
    @stats_hash = {}
    SchoolMonthlyStat.where(name: :students).where("ref_date > ?", Date.civil(2009,12,31)).each do |stat|
      @ref_dates << stat.ref_date
      @stats_hash[stat.ref_date] = {} if @stats_hash[stat.ref_date].nil?
      @stats_hash[stat.ref_date][stat.school_id] = stat.value
    end
    
    @ref_dates.uniq!
    @ref_dates.sort!
    @schools = School.all
    
    respond_to do |format|
      format.csv do
        response.headers['Content-Disposition'] = "attachment; filename=students.csv"
        render 'students.csv.erb'
      end 
    end
  end

  def show
    authorize! :read, Ranking

    @federations = Federation.scoped 
    federation_ids = Federation.accessible_by(current_ability).pluck(:id)
    
    if params[:ranking].nil?
      if params[:federation_id]
        # we'r linking to a specific federation's list
        federation_ids = [params[:federation_id].to_i]
      end
      params[:ranking] = { federation_ids: federation_ids }
    end
    @ranking = Ranking.new params[:ranking]

    schools_scope = School.where(federation_id: params[:ranking][:federation_ids])
                          .where("(cached_nucleo_enabled IS NULL) OR cached_nucleo_enabled")
    if @ranking.school_ids.empty?
      @missing_schools ||= schools_scope
    else
      @missing_schools ||= schools_scope.select([:id, :name, :account_name, :federation_id])
                                 .where("id NOT IN ('#{@ranking.school_ids.join("','")}')")
    end
    
    respond_to do |format|
      format.html { render action: :show }
      format.json do
        render json: @matrix
      end
      format.csv do
        response.headers['Content-Disposition'] = "attachment; filename=rankings.csv"
        render 'show.csv.erb'
      end
    end
  end

  def update
    show
  end

end

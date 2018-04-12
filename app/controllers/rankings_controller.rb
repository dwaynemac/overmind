class RankingsController < ApplicationController
  
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

class RankingsController < ApplicationController
  include ApplicationHelper
  
  def history
    authorize! :history, Ranking
    
    @federations = Federation.all
    # federation_ids = Federation.accessible_by(current_ability).pluck(:id) # solo muestra a cada usuario las escuelas de su federación
    federation_ids = @federations.pluck(:id)
    
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

    @stat_name = @ranking.column_names.first
    @stat_name = @stat_name.first if @stat_name.is_a?(Array)
      
    @ref_dates = []
    @stats_hash = {}
    
    base_scope = SchoolMonthlyStat.where("ref_date >= ?", @ranking.ref_since)
                     .where("ref_date <= ?", @ranking.ref_until)
                     .joins(:school)
                     .where(schools: { federation_id: @ranking.federation_ids })
    stats_scope = base_scope.where(name: @ranking.column_names.first)
                     
    school_ids = stats_scope.pluck(:school_id).uniq
    @schools = School.find school_ids
    
    stats_scope.each do |stat|
      @ref_dates << stat.ref_date
      @stats_hash[stat.ref_date] = {} if @stats_hash[stat.ref_date].nil?
      @stats_hash[stat.ref_date][stat.school_id] = stat
    end
    
    @sums = {}
    @avgs = {}
    @ref_dates.each do |ref_date|
      @sums[ref_date] = ReducedStat.new(
                          name: @stat_name,
                          ref_date: ref_date,
                          stats: @stats_hash[ref_date].values,
                          stats_scope: base_scope.where(ref_date: ref_date),
                          reduce_as: :sum
                        )
      @avgs[ref_date] = ReducedStat.new(
                          name: @stat_name,
                          ref_date: ref_date,
                          stats: @stats_hash[ref_date].values,
                          stats_scope: base_scope.where(ref_date: ref_date, name: @stat_name),
                          reduce_as: :avg
                        )
    end
    @graph_data = if MonthlyStat.is_a_rate?(@stat_name) || (MonthlyStat.default_reduction(@stat_name) == :avg) 
      @avgs
    else
      @sums
    end
    
    @ref_dates.uniq!.sort!
    
    respond_to do |format|
      format.html do
        render layout: "analytics"
      end
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

    @federations = Federation.all
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

    # memoize here for faster rendering.
    @ranking.matrix
    
    respond_to do |format|
      format.html do
        render action: :show, layout: role_layout
      end
      format.json do
        render json: @ranking.matrix
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

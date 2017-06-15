class RankingsController < ApplicationController

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

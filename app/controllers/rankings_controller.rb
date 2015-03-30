class RankingsController < ApplicationController

  def show
    authorize! :read, Ranking

    @federations = Federation.accessible_by(current_ability)
    federation_ids = @federations.pluck(:id)
    
    if params[:ranking].nil?
      if params[:federation_id]
        # we'r linking to a specific federation's list
        federation_ids ? params[:federation_id]
      end
      params[:ranking] = { federation_ids: federation_ids }
    end
    @ranking = Ranking.new params[:ranking]

    if @ranking.school_ids.empty?
      @missing_schools ||= School.where(federation_id: params[:ranking][:federation_ids])
    else
      @missing_schools ||= School.select([:id, :name, :account_name]).where(federation_id: params[:ranking][:federation_ids]).where("id NOT IN ('#{@ranking.school_ids.join("','")}')")
    end
    
    respond_to do |format|
      format.html { render action: :show }
      format.json do
        render json: @matrix
      end
      format.csv do
        response.headers['Content-Disposition'] = "attachment; filename='rankings.csv'"
        render 'show.csv.erb'
      end
    end
  end

  def update
    show
  end

end

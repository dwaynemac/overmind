class RankingsController < ApplicationController

  def show
    authorize! :read, Ranking

    @federations = Federation.accessible_by(current_ability)
    
    if params[:ranking].nil?
      params[:ranking] = { federation_ids: @federations.pluck(:id) }
    end
    @ranking = Ranking.new params[:ranking]
    
    respond_to do |format|
      format.html { render action: :show }
      format.json do
        render json: @matrix
      end
    end
  end

  def update
    show
  end

end

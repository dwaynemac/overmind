class RankingsController < ApplicationController

  def show
    @ranking = Ranking.new(params[:ranking])
    authorize! :read, @ranking

    @matrix = @ranking.matrix

    @missing_schools = School.select([:id, :name]).where("id NOT IN ('#{@ranking.school_ids.join("','")}')")
    @federations = Federation.all
    
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

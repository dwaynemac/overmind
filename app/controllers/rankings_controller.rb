class RankingsController < ApplicationController

  def show
    @ranking = Ranking.new(params[:ranking])
    authorize! :read, @ranking

    @matrix = @ranking.matrix

    @missing_schools = School.select([:name]).where("id NOT IN ('#{@ranking.school_ids.join("','")}')")
    @federations = Federation.all
    
    respond_to do |format|
      format.html
      format.json do
        render json: @matrix
      end
    end
  end

end

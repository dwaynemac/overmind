class RankingsController < ApplicationController

  def show
    @ranking = Ranking.new(params[:ranking])
    authorize! :read, @ranking

    @matrix = @ranking.matrix

    # account_name needed to avoid exception
    @missing_schools = School.select([:id, :name, :account_name]).where("id NOT IN ('#{@ranking.school_ids.join("','")}')")
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

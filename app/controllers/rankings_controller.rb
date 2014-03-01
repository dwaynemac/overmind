class RankingsController < ApplicationController

  def show
    @ranking = Ranking.new(params[:ranking])
    authorize! :read, @ranking

    @matrix = @ranking.matrix

    # account_name needed to avoid exception
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

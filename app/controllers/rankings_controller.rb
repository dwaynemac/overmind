class RankingsController < ApplicationController
  def show

    date = params[:date] || Date.today.end_of_month
    scope = SchoolMonthlyStat.select([:name, :value, :school_id]).includes(:school).where(ref_date: date)
    
    unless params[:filters].nil?
      scope = scope.where(schools: params[:filters]) 
    end
    
    if params[:column_names].nil?
      @column_names = MonthlyStat::VALID_NAMES
    else
      @column_names = params[:column_names]
      scope = scope.where(name: params[:column_names])
    end
    
    @matrix = RankingMatrix.new(scope).matrix
    
    respond_to do |format|
      format.html
      format.json do
        render json: @matrix
      end
    end
  end
end

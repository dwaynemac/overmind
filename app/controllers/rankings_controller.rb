class RankingsController < ApplicationController
  
  DEFAULT_COLUMN_NAMES = [:students, :enrollments, :dropouts, :demand, :interviews] 

  def show

    authorize! :read, :rankings

    date = params[:date] || 1.month.ago.end_of_month.to_date
    scope = SchoolMonthlyStat.select([:name, :value, :school_id]).includes(:school).where(ref_date: date)
    
    unless params[:filters].nil?
      scope = scope.where(schools: params[:filters]) 
    end
    
    if params[:column_names].nil?
      @column_names = DEFAULT_COLUMN_NAMES
    else
      @column_names = params[:column_names]
      scope = scope.where(name: params[:column_names])
    end
    
    @matrix = RankingMatrix.new(scope).matrix
    @federations = Federation.all
    
    respond_to do |format|
      format.html
      format.json do
        render json: @matrix
      end
    end
  end

end

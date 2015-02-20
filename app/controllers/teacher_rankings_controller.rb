class TeacherRankingsController < ApplicationController

  def show
    authorize! :read, TeacherRanking

    @federations = Federation.accessible_by(current_ability)
    federation_ids = @federations.pluck(:id)
    
    @schools = School.accessible_by(current_ability)
    school_ids = @federations.pluck(:id)

    if params[:teacher_ranking].nil?
      params[:teacher_ranking] = { federation_ids: federation_ids, school_ids: school_ids }
    end
    
    @teacher_ranking = TeacherRanking.new params[:teacher_ranking]
    
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

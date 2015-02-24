class TeacherRankingsController < ApplicationController

  def show
    authorize! :read, TeacherRanking

    if params[:school_id]
      @school = School.find(params[:school_id])
    else
      @school = School.find_by_account_name(current_user.account_name)
    end

    @federation = @school.federation if @school

    unless params[:school_id]
      @federations = Federation.accessible_by(current_ability)
      @schools = School.accessible_by(current_ability)
    end
    
    if params[:teacher_ranking].nil?
      params[:teacher_ranking] = { federation_ids: [@federation.id], school_ids: [@school.id] }
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

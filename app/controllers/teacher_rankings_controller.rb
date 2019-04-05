class TeacherRankingsController < ApplicationController

  before_filter :load_school

  def show
    authorize! :read, TeacherRanking

    @federation = @school.federation if @school

    unless params[:school_id]
      @federations = Federation.accessible_by(current_ability)
      @schools = School.accessible_by(current_ability)
    end
    
    if params[:teacher_ranking].nil?
      params[:teacher_ranking] = {}
    end

    @teacher_ranking = TeacherRanking.new params[:teacher_ranking].merge({ federation_ids: [@federation.try(:id)],
                                                                           school_ids: [@school.id] })
    
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

  private

  def load_school
    if School.exists?(params[:school_id])
      @school = School.find(params[:school_id])
    else
      @school = School.where(account_name: params[:school_id]).try :first
    end

    if @school.nil?
      @school = School.find_by_account_name(current_user.account_name)
    end

    if @school.nil?
      raise ActiveRecord::RecordNotFound
    end

    @school
  end

end

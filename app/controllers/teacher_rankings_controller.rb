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
    
    
    unless SyncRequest.on_ref_date(year: @teacher_ranking.ref_date.year, month: @teacher_ranking.ref_date.month)
                      .where(school_id: @school.id)
                      .where(state: %W(ready running paused))
                      .exists?
      sr = SyncRequest.create(year: @teacher_ranking.ref_date.year, month: @teacher_ranking.ref_date.month, school_id: @school.id, priority: 10)
      sr.queue_dj
    end

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

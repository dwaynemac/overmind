# @restful_api v0
class Api::V0::MonthlyStatsController < Api::V0::ApiController

  # @action GET
  # @url /api/v0/monthly_stats
  # @required [String] api_key
  def index
    @monthly_stats = MonthlyStat.all(include: :school)
    render json: {
        collection: @monthly_stats,
        total: @monthly_stats.size
    }
  end

  # @url /api/v0/monthly_stats/:id
  # @action GET
  # @required [String] api_key
  # @required [Integer] id
  # @response Array<MonthlyStat>
  def show
    @monthly_stat = MonthlyStat.find(params[:id])
    render json: @monthly_stat
  end

  # Creates MonthlyStat. If it already exists, existing stat will be updated.
  #
  # @url /api/v0/monthly_stats
  # @action POST
  #
  # @required [String] api_key
  # @required [Hash] monthly_stat
  # @required [String] monthly_stat[account_name]
  # @required [String] monthly_stat[name] stat name. Valid values are:
  #   :enrollments,
  #   :dropouts,
  #   :students,
  #   :assistant_students, # students at Assistant lev
  #   :professor_students, # students at Professor level.
  #   :master_students, # students at Master level.
  #   :interviews, :p_interviews
  #
  # @example_response
  #   id: 1234 - status: 201
  # @response_field id [Integer] id of created/updated monthly_stat (only for status: 201)
  #
  # @example_response {errors: [], message: 'Stat not saved'} - status: 400
  # @response_field errors [Array] (only for status: 400)
  def create
    if @monthly_stat = find_this_stat(params[:monthly_stat])
      @monthly_stat.value = params[:monthly_stat][:value]
      @monthly_stat.service = params[:monthly_stat][:service]
    else
      @monthly_stat = MonthlyStat.new(params[:monthly_stat])
    end
    if @monthly_stat.save!
      render json: {id: @monthly_stat.id}, status: 201
    else
      render json: {
          errors: @monthly_stat.errors,
          message: "Stat not saved"
      }, status: 400
    end
  end

  # @action PUT
  # @url /api/v0/monthly_stats/:id
  # @required [String] api_key
  # @retuired [Integer] id
  def update
    @monthly_stat = MonthlyStat.find(params[:id])
    if @monthly_stat.update_attributes params[:monthly_stat]
      render json: 'ok'
    else
      render json: {
          message: 'Stat not saved',
          errors: @monthly_stat.errors
      }, status: 400
    end
  end

  # @url /api/v0/monthly_stats/:id
  # @action DELETE
  # @required [String] api_key
  # @required [Integer] id
  def destroy
    @monthly_stat = MonthlyStat.find(params[:id])
    @monthly_stat.destroy
    render json: 'ok', status: 200
  end

  private

  # Finds MonthlyStat duplicate
  # @param [Hash] attributes
  # @return [MonthlyStat]
  def find_this_stat(attributes)
    school = School.find_by_account_name(attributes[:account_name])
    MonthlyStat.where(name: attributes[:name], ref_date: attributes[:ref_date], school_id: school.try(:id)).first
  end

end
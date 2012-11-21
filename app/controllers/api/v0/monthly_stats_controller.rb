# @url /v0/monthly_stat
# @topic MonthlyStat
class Api::V0::MonthlyStatsController < Api::V0::ApiController

  # GET /api/v0/monthly_stats
  def index
    @monthly_stats = MonthlyStat.all(include: :school)
    render json: {
        collection: @monthly_stats,
        total: @monthly_stats.size
    }
  end

  # GET /api/v0/monthly_stats/:id
  def show
    @monthly_stat = MonthlyStat.find(params[:id])
    render json: @monthly_stat
  end

  # Creates MonthlyStat. If it already exists, existing stat will be updated.
  #
  # @url [POST] /api/v0/monthly_stats
  #
  # @required_argument [Hash] monthly_stat
  # @keys_for monthly_stat [String] account_name
  #
  # @example_response { id: 1234 } - status: 201
  # @response_code 201
  # @example_response {errors: [], message: 'Stat not saved'} - status: 400
  # @response_code 400
  #
  # @response_field id [Integer] id of created/updated monthly_stat (only for status: 201)
  # @response_field errors [Array] (only for status: 400)
  def create

    if @monthly_stat = find_this_stat(params[:monthly_stat])
      @monthly_stat.value = params[:monthly_stat][:value]
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

  # PUT /api/v0/monthly_stats/:id
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

  # DELETE /api/v0/monthly_stats/:id
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
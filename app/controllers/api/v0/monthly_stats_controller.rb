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

  # POST /api/v0/monthly_stats
  def create
    @monthly_stat = MonthlyStat.create(params[:monthly_stat])
    if @monthly_stat.save
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

end
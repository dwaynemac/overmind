class FederationsController < ApplicationController
  include ApplicationHelper

  load_and_authorize_resource

  def index
    @dropouts_sums = {}
    @dropouts_rates = {}
    
    @federations.each do |federation|
      
      @dropouts_sums[federation.id] = SchoolMonthlyStat.where(name: :dropouts)
                                                        .where(school_id: federation.schools.map(&:id))
                                                        .where("ref_date >= ?", 13.months.ago )
                                                        .sum(:value)
      int_value = LocalStat.new.calculate_dropout_rate(
        dropouts: @dropouts_sums[federation.id],
        students: SchoolMonthlyStat.where(name: :students)
                                    .where(school_id: federation.schools.map(&:id))
                                    .where("ref_date >= ?", 13.months.ago )
                                    .sum(:value)
      )
      if int_value
        @dropouts_rates[federation.id] = int_value / 100.0
      end
    end

    render layout: role_layout
  end

  def show
    @years = (2010..Date.today.year)
    @year = params[:year] || Date.today.year
    @monthly_stats = @federation.school_monthly_stats.for_year(@year).to_matrix
    respond_to do |format|
      format.html
      format.csv do
        response.headers['Content-Disposition'] = "attachment; filename='#{@federation.name}_#{@year}.csv'"
        render 'show.csv.erb'
      end
    end

    render layout: role_layout
  end

  def new

  end

  def create
    if @federation.save
      redirect_to federations_path, notice: t('federations.create.success')
    else
      render :new
    end
  end

  def edit

  end

  def update
    if @federation.update_attributes(params[:federation])
      redirect_to federations_path, notice: t('federations.update.success')
    else
      render :edit
    end
  end

  def destroy
    @federation.destroy
    redirect_to federations_path, notice: t('federations.destroy.success')
  end

end

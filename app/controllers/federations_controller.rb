class FederationsController < ApplicationController
  include ApplicationHelper

  load_and_authorize_resource

  def index
    @dropouts_sums = {}
    @dropouts_rates = {}
    @schools_sums = {}
    @students_sums = {}
    @teachers_sums = {}

    @ref_since = 1.year.ago.end_of_month.to_date
    @ref_until = Date.today.end_of_month.to_date
    
    @federations.each do |federation|
      @schools_sums[federation.id] = federation.schools.enabled_on_nucleo.count

      @teachers_sums[federation.id] = SchoolMonthlyStat.where(name: :team_teachers)
                                                      .joins(:school).where(schools: { federation_id: federation.id })
                                                      .where(ref_date: @ref_until)
                                                      .sum(:value)

      @students_sums[federation.id] = SchoolMonthlyStat.where(name: :students)
                                                      .joins(:school).where(schools: { federation_id: federation.id })
                                                      .where(ref_date: @ref_until)
                                                      .sum(:value)
      
      @dropouts_sums[federation.id] = SchoolMonthlyStat.where(name: :dropouts)
                                                        .where(school_id: federation.schools.map(&:id))
                                                        .where("ref_date >= ? and ref_date <= ?", @ref_since, @ref_until )
                                                        .sum(:value)
      int_value = LocalStat.new.calculate_dropout_rate(
        dropouts: @dropouts_sums[federation.id],
        students: SchoolMonthlyStat.where(name: :students)
                                    .where(school_id: federation.schools.map(&:id))
                                    .where("ref_date >= ? and ref_date <= ?", @ref_since, @ref_until )
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
      format.html do
        render layout: role_layout
      end
      format.csv do
        response.headers['Content-Disposition'] = "attachment; filename='#{@federation.name}_#{@year}.csv'"
        render 'show.csv.erb'
      end
    end
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

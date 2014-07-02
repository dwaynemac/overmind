class ReportsController < ApplicationController
  layout 'reports'
  
  def marketing_snapshot
    @televisits = 2564
    @calls = 2000
    @visits = 1860
    @fp = 189
    @perfil = 1600
    @enrollments = 1129
    @convertion = 10
    @demand = 300
  end

  def pedagogic_snapshot
    
    #widget
    @enrollments = 3568
    @dropouts = 2568
    @students = 1236
    @growth = 3
    
    #graph
    @begginers = 600
    @sadhakas = 400
    @yogins = 500
    @chelas = 200
    @graduados = 300
    @assistants = 250
    @professors = 420
    
    #left pie chart
    @male_students = 30
    @female_students = 70
    @students_avg_age = 18
    
    #right pie chart
    @begginer = 60
    @graduate = 30
    @senior = 10
  end
end

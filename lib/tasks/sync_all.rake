namespace :sync do

  desc 'syncs all, To filter it will read from environment: federation_id, school_id and year (all optional)'
  task :all => :environment do
    schools = []
    if ENV['federation_id']
      schools = Federation.find(ENV['federation_id']).schools
    elsif ENV['school_id']
      schools = School.where(id: ENV['school_id'])
    else
      schools = School.all
    end
    schools.each do |school|
      if school.padma_enabled?
        puts "syncing #{school.name}"
        if ENV['year']
          year = (ENV['year'] == 'current')? Date.today.year : ENV['year']
          school.sync_year_stats(year,update_existing: true)
        else
          (2010..Time.zone.today.year).each do |year|
            puts "    #{year}"
            school.sync_year_stats(year,update_existing: true)
          end
        end
      else
        puts "#{school.name}\t\thas no service to sync"
      end
    end
  end

  desc "Syncs current year, only on the 1st of the month."
  task :current_year_on_the_first => :environment do
    today = Date.today
    if today.day == 1
      School.all.each do |school|
        if school.padma_enabled?
          school.sync_year_stats(today.year, update_existing: true)
        end
      end
    end
  end

  desc "Syncs current year, only on mondays."
  task :current_year_on_sundays => :environment do
    today = Date.today
    if today.wday == 0
      School.all.each do |school|
        if school.padma_enabled?
          school.sync_year_stats(today.year, update_existing: true)
        end
      end
    end
  end
end

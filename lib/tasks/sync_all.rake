task :sync_all => :environment do
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
        school.sync_year_stats(ENV['year'],update_existing: true)
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
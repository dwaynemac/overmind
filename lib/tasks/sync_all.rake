task :sync_all => :environment do
  School.all.each do |school|
    if school.padma_enabled?
      puts "syncing #{school.name}"
      (2010..Time.zone.today.year).each do |year|
        puts "    #{year}"
        school.sync_year_stats(year,update_existing: true)
      end
    else
      puts "#{school.name}\t\thas no service to sync"
    end
  end
end
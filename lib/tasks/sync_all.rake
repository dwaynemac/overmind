namespace :sync do

  desc 'Sync worker, will constantly poll for pending sync_requests'
  task :worker => :environment do
    puts "Starting sync:worker"
    begin
      loop do
        begin
          SyncRequest.pending.each do |sr|
            puts "running SyncRequest##{sr.id}"
            sr.start
          end
        rescue StandardError => e
          puts "Exception in sync:worker: #{e.message}"
        end
      end
    rescue SignalException => e
      puts "Signal to sync:worker: #{e.message}"
    end
    puts "exiting sync:worker"
  end
  
  desc 'Run all pending SyncRequest'
  task :run_all_requested => :environment do
    SyncRequest.pending.each do |sr|
      sr.start
    end
  end

  desc "Destroy all finished SyncRequest"
  task :clear_finished_requests => :environment do
    SyncRequest.finished.destroy_all
  end

  desc 'Queue sync for all, To filter it will read from environment: federation_id, school_id and year (all optional)'
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
        puts "queueing sync for #{school.name}"
        if ENV['year']
          year = (ENV['year'] == 'current')? Date.today.year : ENV['year']
          SyncRequest.create(school_id: school.id, year: year)
        else
          (2010..Time.zone.today.year).each do |year|
            puts "    #{year}"
            SyncRequest.create(school_id: school.id, year: year)
          end
        end
      else
        puts "#{school.name}\t\thas no service to sync"
      end
    end
  end

  desc "Queues syncs for current year, only on the 1st of the month."
  task :current_year_on_the_first => :environment do
    today = Date.today
    if today.day == 1
      School.all.each do |school|
        if school.padma_enabled?
          SyncRequest.create(school_id: school.id, year: today.year)
        end
      end
    end
  end

  desc "Queues syncs for current year, only on mondays."
  task :current_year_on_sundays => :environment do
    today = Date.today
    if today.wday == 0
      School.all.each do |school|
        if school.padma_enabled?
          SyncRequest.create(school_id: school.id, year: today.year)
        end
      end
    end
  end

  desc "Queues syncs for current year."
  task :current_year => :environment do
    today = Date.today
    School.all.each do |school|
      if school.padma_enabled?
        SyncRequest.create(school_id: school.id, year: today.year)
      end
    end
  end
end

task :check_for_errors => :environment do
  if Date.today.wday == 6 || ENV['FORCE_CHECK_FOR_ERRORS']
    @schools = School.enabled_on_padma.all
    
    i = 12

    # rates over 100%
    MonthlyStat.where("name like '%rate'").where("value > 10000").delete_all
    
    while(i >= 0) do
      ref_month = i.months.ago
      
      puts "checking month: #{ref_month} ========================================"
      
      puts "global students checksum"
      if Checksum.global_students(ref_month: ref_month) # quick global check.
        puts "ok"
      else
        puts "failed"
        
        # only check school by school if global failed
        @schools.each do |school|
          puts "checking school #{school.quick_name} ============="
          
          puts "students checksum"
          if Checksum.students(ref_month: ref_month, school_id: school.id)
            puts "ok"
          else
            puts "failed"
            
            if school.padma_enabled?
              puts "queueing sync request for #{ref_month}"
              sr = SyncRequest.create(school_id: school.id,
                                 priority: 6, # not night only but bellow manual sync requests.
                                 year: ref_month.year,
                                 month: ref_month.month)
              sr.queue_dj
              puts "queueing sync request for #{(ref_month-1.month)}"
              sr = SyncRequest.create(school_id: school.id,
                                 priority: 6, # not night only but bellow manual sync requests.
                                 year: (ref_month-1.month).year,
                                 month: (ref_month-1.month).month)
              sr.queue_dj
            else
              puts "padma not enabled. doing nothing.."
            end
          end
        end
      end
      
      i -= 1
    end
  end
end

task :check_for_errors => :environment do
  
  i = 12
  
  while(i >= 0) do
    ref_month = i.months.ago
    
    puts "checking month: #{ref_month}"
    
    puts "global students checksum"
    if Checksum.global_students(ref_month: ref_month) # quick global check.
      puts "ok"
    else
      puts "failed"
      
      # only check school by school if global failed
      School.all.each do |school|
        puts "checking school #{school.quick_name} ============="
        
        puts "students checksum"
        if Checksum.students(ref_month: ref_month, school_id: school.id)
          puts "ok"
        else
          puts "failed"
          
          puts "queueing sync request"
          SyncRequest.create(school_id: school_id,
                             year: ref_month.year,
                             month: ref_month.month)
        end
      end
    end
    
    i -= 1
  end
end
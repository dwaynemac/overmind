task :refresh_schools_last_students_count => :environment do
  School.all.each do |school|
    school.cache_last_student_count
  end
end
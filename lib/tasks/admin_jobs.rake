task :update_services => :environment do
  MonthlyStat.where("ref_date > ?",Date.civil(2013,6,1)).each do |ms|
    old_service = ms.service
    ms.set_service
    new_service = ms.service
    if old_service != new_service && ms.save
      Rails.logger.debug "[#{ms.id}] updated service #{old_service} -> #{new_service}"
    end
  end
end

task :calculate_enrollment_rate => :environment do
  SchoolMonthlyStat.where(name: :enrollments).each do |ms|
    Rails.logger.debug "calculating enrollment_rate for school #{ms.school.id} on #{ms.ref_date}"
    SchoolMonthlyStat.create_from_service!(ms.school, :enrollment_rate, ms.ref_date)
  end
end

task :calculate_dropout_rate => :environment do
  SchoolMonthlyStat.where(name: :dropouts).each do |ms|
    Rails.logger.debug "calculating dropout_rate for school #{ms.school.id} on #{ms.ref_date}"
    SchoolMonthlyStat.create_from_service!(ms.school, :dropout_rate, ms.ref_date)
  end
end

task :calculate_male_students_rate => :environment do
  SchoolMonthlyStat.where(name: :male_students).each do |ms|
    Rails.logger.debug "calculating male_students for school #{ms.school.id} on #{ms.ref_date}"
    SchoolMonthlyStat.create_from_service!(ms.school, :male_students_rate, ms.ref_date)
  end
end

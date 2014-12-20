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

task :calculate_local_stats => :environment do
  dependency = {
    male_students_rate: :male_students,
    aspirante_students_rate: :aspirante_students,
    sadhaka_students_rate: :sadhaka_students,
    yogin_students_rate: :yogin_students,
    chela_students_rate: :chela_students,
    begginers_dropout_rate: :dropouts_begginers,
    swasthya_dropout_rate: :dropouts_intermediates,
    enrollment_rate: :enrollments,
    dropout_rate: :dropouts
  }
  LocalStat::NAMES.each do |local_stat_name|
    SchoolMonthlyStat.where(name: dependency[local_stat_name]).each do |ms|
      Rails.logger.debug "calculating #{local_stat_name} for school #{ms.school.id} on #{ms.ref_date}"
      SchoolMonthlyStat.create_from_service!(ms.school, local_stat_name, ms.ref_date)
    end
  end
end

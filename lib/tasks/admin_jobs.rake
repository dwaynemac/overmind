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
  LocalStat.calculate_all
end

task :recalculate_local_rates => :environment do
  SchoolMonthlyStat.where(service: 'overmind').where(name: [
      :conversion_rate,
      :begginers_dropout_rate,
      :swasthya_dropout_rate,
      :enrollment_rate,
      :dropout_rate,

      :male_students_rate,

      :aspirante_students_rate,
      :sadhaka_students_rate,
      :yogin_students_rate,
      :chela_students_rate
    ]).each do |sm|
      puts "recalculating school_monthly_stat #{sm.name} for #{sm.ref_date} for #{sm.school.account_name}"
      sm.update_from_service!
  end
  TeacherMonthlyStat.where(service: 'overmind').where(name: [
      :conversion_rate,
      :begginers_dropout_rate,
      :swasthya_dropout_rate,
      :enrollment_rate,
      :dropout_rate,

      :male_students_rate,

      :aspirante_students_rate,
      :sadhaka_students_rate,
      :yogin_students_rate,
      :chela_students_rate
    ]).each do |tm|
        puts "recalculating teacher monthly stat #{tm.name} for #{tm.ref_date} for #{tm.teacher.name} on  #{tm.school.account_name}"
        value = TeacherMonthlyStat.calculate_local_value(tm.school,tm.teacher,tm.name,tm.ref_date)
        tm.update_attribute :value, value
  end
end

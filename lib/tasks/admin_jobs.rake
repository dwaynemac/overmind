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

task :recalculate_local_rates => :environment do
  SchoolMonthlyStat.where(service: 'overmind').where("value <= 100").where(name: [
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
    ]).find_each(batch_size: 50) do |sm|
      puts "recalculating school_monthly_stat #{sm.name} for #{sm.ref_date} for #{sm.school.account_name}"
      sm.update_from_service!
  end
  TeacherMonthlyStat.where(service: 'overmind').where("value <= 100").where(name: [
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
    ]).find_each(batch_size: 50) do |tm|
        puts "recalculating teacher monthly stat #{tm.name} for #{tm.ref_date} for #{tm.teacher.name} on  #{tm.school.account_name}"
        value = TeacherMonthlyStat.calculate_local_value(tm.school,tm.teacher,tm.name,tm.ref_date)
        tm.update_attribute :value, value
  end
end

task :calculate_gender_demand => :environment do
  [2016,2015,2014].each do |year|
    (1..12).each do |month|
      ref = Date.civil(year,month,1).end_of_month
      School.all.each do |school|
        if school.padma_enabled? # school in the inner loops means more calls but also syncing chronologically
          %W(male_demand female_demand male_interviews female_interviews male_demand_rate female_demand_rate male_interviews_rate female_interviews_rate).each do |stat_name|
            SchoolMonthlyStat.sync_from_service!(school,stat_name,ref)
          end
        end
      end
    end
  end
end

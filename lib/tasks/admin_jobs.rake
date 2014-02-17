task :update_services => :environment do
  MonthlyStat.where("ref_date > ?",Date.civil(2012,11,30)).each do |ms|
    old_service = ms.service
    ms.set_service
    new_service = ms.service
    if old_service != new_service && ms.save
      Rails.logger.debug "[#{ms.id}] updated service #{old_service} -> #{new_service}"
    end
  end
end

task :export_nucleo_ids_to_accounts => :environment do
  School.where("nucleo_id is not null and account_name is not null").each do |s|
    a = s.account
    a.nucleo_id = s.nucleo_id
    a.save
  end
end

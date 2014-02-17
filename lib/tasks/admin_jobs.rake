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

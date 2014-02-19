require 'schools_synchronizer'

desc "Synchronizes schools with padma-accounts"
task synchronize_schools: :environment do
  SchoolsSynchronizer.start
end

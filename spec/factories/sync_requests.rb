# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :sync_request do
    school
    year {2013}
    month {1}
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :federation do
    sequence(:name){|n|"fed#{n}"}
    sequence(:nucleo_id)
  end
end

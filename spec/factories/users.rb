# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do

  factory :user do
    sequence(:username){|n|"user#{n}"}
  end
end

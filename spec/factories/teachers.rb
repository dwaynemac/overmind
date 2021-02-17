# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :teacher do
    sequence(:username) { |i| "user#{i}" }
    full_name {"MyString"}
  end
end

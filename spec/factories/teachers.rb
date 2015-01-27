# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :teacher do
    sequence(:username) { |i| "user#{i}" }
    full_name "MyString"
  end
end

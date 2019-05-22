# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :school do
    sequence(:name){|n|"school#{n}"}
    sequence :nucleo_id do |i|
      i 
    end
  end
end

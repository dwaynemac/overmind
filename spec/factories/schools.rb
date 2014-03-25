# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :school do
    sequence(:name){|n|"school#{n}"}
    sequence :nucleo_id do |i|
      i 
    end
  end
end

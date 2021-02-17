# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :school_monthly_stat do
    name {'enrollments_count'}
    value {10}
    ref_date { Date.today.end_of_month }
    school
  end
end

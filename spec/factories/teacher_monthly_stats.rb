# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :teacher_monthly_stat do
    teacher
    name 'enrollments_count'
    value 10
    ref_date { Date.today.end_of_month }
    school
  end
end

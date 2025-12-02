FactoryBot.define do
  factory :course do
    sequence(:name) { |n| "Course #{n}" }
    sequence(:code) { |n| "CS#{n}" }
    classCode { "A" }
    semester { "2024.1" }
    association :teacher, factory: :user
  end
end

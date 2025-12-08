FactoryBot.define do
  factory :enrollment do
    association :student, factory: :user
    association :course
  end
end

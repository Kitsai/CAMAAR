FactoryBot.define do
  factory :template do
    name { "Sample Template" }
    association :admin
    association :question_set

    trait :with_questions do
      after(:build) do |template|
        template.question_set ||= build(:question_set)
      end
    end
  end
end

FactoryBot.define do
  factory :form do
    association :admin
    association :course
    association :question_set
  end
end

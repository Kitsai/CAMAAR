FactoryBot.define do
  factory :answer do
    association :form
    data { "5,Great teaching" }
  end
end

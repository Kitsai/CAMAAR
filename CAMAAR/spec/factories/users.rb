FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "Test User" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :admin do
      after(:create) do |user|
        create(:admin, user: user)
      end
    end
  end
end

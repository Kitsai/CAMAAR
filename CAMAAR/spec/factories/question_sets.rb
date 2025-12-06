FactoryBot.define do
  factory :question_set do
    data do
      [
        { question: "What is your name?", type: "text" },
        { question: "How would you rate this course?", type: "scale", min: 1, max: 5 },
        { question: "What did you like most?", type: "text" }
      ]
    end

    trait :single_question do
      data do
        [
          { question: "Single question?", type: "text" }
        ]
      end
    end

    trait :empty do
      data { [] }
    end
  end
end

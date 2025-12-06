FactoryBot.define do
  factory :question_set do
    data do
      [
        { question: "What is your name?", type: "text" },
        { question: "How would you rate this course?", type: "radio", options: ["Excellent", "Good", "Average", "Poor", "Very Poor"] },
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

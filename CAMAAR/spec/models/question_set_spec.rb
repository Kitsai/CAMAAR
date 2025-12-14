require 'rails_helper'

RSpec.describe QuestionSet, type: :model do
  describe "validations" do
    it "is valid with a non-empty array of questions" do
      question_set = QuestionSet.new(data: [ { question: "Test?", type: "text" } ])
      expect(question_set).to be_valid
    end

    it "requires data to be present" do
      question_set = QuestionSet.new(data: nil)
      expect(question_set).not_to be_valid
      expect(question_set.errors[:data]).to include("can't be blank")
    end

    it "requires data to be a non-empty array" do
      question_set = QuestionSet.new(data: [])
      expect(question_set).not_to be_valid
      expect(question_set.errors[:data]).to include("must be a non-empty array of questions")
    end

    it "is invalid when data is not an array" do
      question_set = QuestionSet.new(data: "not an array")
      expect(question_set).not_to be_valid
      expect(question_set.errors[:data]).to include("must be a non-empty array of questions")
    end
  end

  describe "associations" do
    it "has one template" do
      expect(QuestionSet.reflect_on_association(:template)).to be_present
      expect(QuestionSet.reflect_on_association(:template).macro).to eq(:has_one)
    end

    it "has many forms" do
      expect(QuestionSet.reflect_on_association(:forms)).to be_present
      expect(QuestionSet.reflect_on_association(:forms).macro).to eq(:has_many)
    end
  end

  describe "updates" do
    let(:question_set) { QuestionSet.create!(data: [ { question: "Original", type: "text" } ]) }

    it "updates the question_set data directly" do
      original_id = question_set.id
      question_set.update(data: [ { question: "Updated", type: "text" } ])
      question_set.reload
      expect(question_set.id).to eq(original_id)
      expect(question_set.data).to eq([ { "question" => "Updated", "type" => "text" } ])
    end
  end
end

require 'rails_helper'

RSpec.describe QuestionSet, type: :model do
  describe "validations" do
    it "is valid with factory" do
      question_set = build(:question_set)
      expect(question_set).to be_valid
    end

    context "when data is nil" do
      subject { build(:question_set, data: nil) }
      include_examples "fails custom validation", :data, "can't be blank"
    end

    context "when data is empty array" do
      subject { build(:question_set, :empty) }
      include_examples "fails custom validation", :data, "must be a non-empty array of questions"
    end

    context "when data is not an array" do
      subject { build(:question_set, data: "not an array") }
      include_examples "fails custom validation", :data, "must be a non-empty array of questions"
    end
  end

  describe "associations" do
    it "has one template" do
      association = QuestionSet.reflect_on_association(:template)
      expect(association).to be_present
      expect(association.macro).to eq(:has_one)
    end

    it { verify_has_many(QuestionSet, :forms) }
  end

  describe "updates" do
    let(:question_set) { QuestionSet.create!(data: [ { question: "Original", type: "text" } ]) }

    it "updates the question_set data directly" do
      expect_question_set_updated_in_place(question_set, [ { "question" => "Updated", "type" => "text" } ]) do
        question_set.update(data: [ { question: "Updated", type: "text" } ])
      end
    end
  end
end

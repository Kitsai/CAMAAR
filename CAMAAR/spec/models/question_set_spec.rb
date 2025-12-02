require 'rails_helper'

RSpec.describe QuestionSet, type: :model do
  describe "validations" do
    it "is valid with a non-empty array of questions" do
      question_set = QuestionSet.new(data: [{ question: "Test?", type: "text" }])
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

  describe "copy-on-write behavior" do
    let(:admin) { create(:user, :admin).admin }
    let(:question_set) { QuestionSet.create!(data: [{ question: "Original", type: "text" }]) }
    let(:template) { Template.create!(name: "Test Template", admin: admin, question_set: question_set) }

    context "when question_set is not used by any forms" do
      it "updates the question_set directly" do
        original_id = question_set.id
        question_set.update(data: [{ question: "Updated", type: "text" }])
        question_set.reload
        expect(question_set.id).to eq(original_id)
        expect(question_set.data).to eq([{ "question" => "Updated", "type" => "text" }])
      end
    end

    context "when question_set is used by forms" do
      let(:course) { Course.create!(name: "Test Course", code: "CS101", teacher: create(:user)) }
      let!(:form) { Form.create!(admin: admin, course: course, question_set: question_set) }

      it "creates a new question_set instead of updating" do
        # Ensure template is loaded first
        template

        original_id = question_set.id
        question_set.update(data: [{ question: "Modified", type: "text" }])

        # Original question_set should remain unchanged
        question_set.reload
        expect(question_set.data).to eq([{ "question" => "Original", "type" => "text" }])

        # Template should point to a new question_set
        template.reload
        expect(template.question_set_id).not_to eq(original_id)
        expect(template.question_set.data).to eq([{ "question" => "Modified", "type" => "text" }])
      end

      it "keeps the original question_set for existing forms" do
        original_id = question_set.id
        question_set.update(data: [{ question: "Modified", type: "text" }])

        form.reload
        expect(form.question_set_id).to eq(original_id)
        expect(form.question_set.data).to eq([{ "question" => "Original", "type" => "text" }])
      end
    end
  end
end

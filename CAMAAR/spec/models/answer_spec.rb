require 'rails_helper'

RSpec.describe Answer, type: :model do
  let(:admin_user) { create(:user, :admin) }
  let(:admin) { admin_user.admin }
  let(:course) { create(:course) }
  let(:question_set) { create(:question_set) }
  let(:form) { create(:form, admin: admin, course: course, question_set: question_set) }

  describe "associations" do
    it "belongs to form" do
      association = described_class.reflect_on_association(:form)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    it "is valid with required attributes" do
      answer = Answer.new(
        form: form,
        data: "Test answer"
      )
      expect(answer).to be_valid
    end

    it "requires a form" do
      answer = Answer.new(data: "Test answer")
      expect(answer).not_to be_valid
      expect(answer.errors[:form]).to include("must exist")
    end
  end

  describe "data attribute" do
    it "stores CSV data with only answers" do
      csv_data = "5,Great course!"
      answer = Answer.create!(
        form: form,
        data: csv_data
      )

      expect(answer.data).to be_present
      expect(answer.data).to eq(csv_data)
      answers = answer.data.split(",")
      expect(answers.first).to eq("5")
      expect(answers.last).to eq("Great course!")
    end
  end

  describe "relationship with form" do
    it "can have multiple answers for the same form" do
      answer1 = Answer.create!(form: form, data: "Answer 1")
      answer2 = Answer.create!(form: form, data: "Answer 2")

      expect(form.answers.count).to eq(2)
      expect(form.answers).to include(answer1, answer2)
    end

    it "is destroyed when form is destroyed" do
      answer = Answer.create!(form: form, data: "Test data")
      answer_id = answer.id

      expect { form.destroy }.to change { Answer.count }.by(-1)
      expect(Answer.find_by(id: answer_id)).to be_nil
    end
  end
end

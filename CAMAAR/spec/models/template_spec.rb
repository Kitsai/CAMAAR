require 'rails_helper'

RSpec.describe Template, type: :model do
  let(:admin) { create(:user, :admin).admin }
  let(:question_set) { QuestionSet.create!(data: [ { question: "Test question", type: "text" } ]) }

  describe "validations" do
    it "is valid with name, admin, and question_set with questions" do
      template = Template.new(
        name: "Test Template",
        admin: admin,
        question_set: question_set
      )
      expect(template).to be_valid
    end

    it "requires a name" do
      template = Template.new(admin: admin, question_set: question_set)
      expect(template).not_to be_valid
      expect(template.errors[:name]).to include("can't be blank")
    end

    it "requires a question_set" do
      template = Template.new(name: "Test Template", admin: admin)
      expect(template).not_to be_valid
      expect(template.errors[:question_set]).to include("must exist")
    end

    it "requires question_set to have at least one question" do
      empty_qs = QuestionSet.new(data: [])
      template = Template.new(
        name: "Test Template",
        admin: admin,
        question_set: empty_qs
      )
      expect(template).not_to be_valid
      expect(template.errors[:question_set]).to include("must have at least one question")
    end

    it "is invalid when question_set data is nil" do
      nil_qs = QuestionSet.new(data: nil)
      template = Template.new(
        name: "Test Template",
        admin: admin,
        question_set: nil_qs
      )
      expect(template).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to admin" do
      expect(Template.reflect_on_association(:admin)).to be_present
      expect(Template.reflect_on_association(:admin).macro).to eq(:belongs_to)
    end

    it "belongs to question_set" do
      expect(Template.reflect_on_association(:question_set)).to be_present
      expect(Template.reflect_on_association(:question_set).macro).to eq(:belongs_to)
    end

    it "accepts nested attributes for question_set" do
      expect(Template.nested_attributes_options).to have_key(:question_set)
    end
  end

  describe "creating template with nested question_set" do
    it "can create template with nested question_set attributes" do
      template = admin.templates.build(
        name: "Nested Template",
        question_set_attributes: {
          data: [ { question: "Nested question", type: "text" } ]
        }
      )
      expect(template.save).to be true
      expect(template.question_set).to be_persisted
      expect(template.question_set.data).to eq([ { "question" => "Nested question", "type" => "text" } ])
    end
  end
end

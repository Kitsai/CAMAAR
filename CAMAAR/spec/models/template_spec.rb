require 'rails_helper'

RSpec.describe Template, type: :model do
  let(:admin) { create(:user, :admin).admin }
  let(:question_set) { QuestionSet.create!(data: [ { question: "Test question", type: "text" } ]) }

  describe "validations" do
    it "is valid with factory" do
      template = build(:template)
      expect(template).to be_valid
    end

    include_examples "requires presence of", :name
    include_examples "requires association", :question_set

    context "when question_set has no questions" do
      subject { build(:template, question_set: build(:question_set, :empty)) }
      include_examples "fails custom validation", :question_set, "must have at least one question"
    end

    context "when question_set data is nil" do
      subject { build(:template, question_set: build(:question_set, data: nil)) }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end
  end

  describe "associations" do
    it "belongs to admin" do
      verify_belongs_to(Template, :admin)
    end

    it "belongs to question_set" do
      verify_belongs_to(Template, :question_set)
    end

    it "accepts nested attributes for question_set" do
      expect(Template.nested_attributes_options).to have_key(:question_set)
    end
  end

  describe "creating template with nested question_set" do
    it "can create template with nested question_set attributes" do
      question_data = [ { question: "Nested question", type: "text" } ]
      template = build_template_with_nested_question_set(admin, "Nested Template", question_data)
      expect_template_saved_with_nested_question_set(template, [ { "question" => "Nested question", "type" => "text" } ])
    end
  end
end

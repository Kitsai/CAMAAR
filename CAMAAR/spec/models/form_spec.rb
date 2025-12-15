require 'rails_helper'

RSpec.describe Form, type: :model do
  let(:admin_user) { create(:user, :admin) }
  let(:admin) { admin_user.admin }
  let(:course) { create(:course) }
  let(:question_set) { create(:question_set) }

  describe "associations" do
    it "belongs to admin" do
      association = described_class.reflect_on_association(:admin)
      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to course" do
      association = described_class.reflect_on_association(:course)
      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to question_set" do
      association = described_class.reflect_on_association(:question_set)
      expect(association.macro).to eq(:belongs_to)
    end

    it "has many form_requests" do
      association = described_class.reflect_on_association(:form_requests)
      expect(association.macro).to eq(:has_many)
    end

    it "has many users through form_requests" do
      expect_has_many_through(described_class, :users, through: :form_requests)
    end

    it "has many answers" do
      association = described_class.reflect_on_association(:answers)
      expect(association.macro).to eq(:has_many)
    end
  end

  describe "validations" do
    it "is valid with factory" do
      form = build(:form)
      expect(form).to be_valid
    end

    include_examples "requires association", :admin
    include_examples "requires association", :course
    include_examples "requires association", :question_set
  end

  describe "scopes and queries" do
    let!(:admin1) { create(:user, :admin).admin }
    let!(:admin2) { create(:user, :admin).admin }
    let!(:course1) { create(:course) }
    let!(:course2) { create(:course) }
    let!(:qs) { create(:question_set) }

    let!(:form1) { create(:form, admin: admin1, course: course1, question_set: qs) }
    let!(:form2) { create(:form, admin: admin1, course: course2, question_set: qs) }
    let!(:form3) { create(:form, admin: admin2, course: course1, question_set: qs) }

    it "can filter forms by admin" do
      expect_forms_filtered_by(:admin, admin1, form1, form2, excluded: [form3])
    end

    it "can filter forms by course" do
      expect_forms_filtered_by(:course, course1, form1, form3, excluded: [form2])
    end
  end

  describe "form requests relationship" do
    it "can have multiple form requests" do
      form = create(:form, admin: admin, course: course, question_set: question_set)
      user1 = create(:user)
      user2 = create(:user)

      create_form_requests_for(form, user1, user2)
      expect_form_has_requests(form, 2, user1, user2)
    end
  end

  describe "answers relationship" do
    it "can have multiple answers" do
      form = create(:form, admin: admin, course: course, question_set: question_set)

      answers = create_answers_for(form, "Answer 1", "Answer 2")
      expect_form_has_answers_count(form, 2, *answers)
    end
  end
end

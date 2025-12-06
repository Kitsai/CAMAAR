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
      association = described_class.reflect_on_association(:users)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:form_requests)
    end

    it "has many answers" do
      association = described_class.reflect_on_association(:answers)
      expect(association.macro).to eq(:has_many)
    end
  end

  describe "validations" do
    it "is valid with all required attributes" do
      form = Form.new(
        admin: admin,
        course: course,
        question_set: question_set
      )
      expect(form).to be_valid
    end

    it "requires an admin" do
      form = Form.new(course: course, question_set: question_set)
      expect(form).not_to be_valid
      expect(form.errors[:admin]).to include("must exist")
    end

    it "requires a course" do
      form = Form.new(admin: admin, question_set: question_set)
      expect(form).not_to be_valid
      expect(form.errors[:course]).to include("must exist")
    end

    it "requires a question_set" do
      form = Form.new(admin: admin, course: course)
      expect(form).not_to be_valid
      expect(form.errors[:question_set]).to include("must exist")
    end
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
      admin1_forms = Form.where(admin: admin1)
      expect(admin1_forms).to include(form1, form2)
      expect(admin1_forms).not_to include(form3)
    end

    it "can filter forms by course" do
      course1_forms = Form.where(course: course1)
      expect(course1_forms).to include(form1, form3)
      expect(course1_forms).not_to include(form2)
    end
  end

  describe "form requests relationship" do
    it "can have multiple form requests" do
      form = create(:form, admin: admin, course: course, question_set: question_set)
      user1 = create(:user)
      user2 = create(:user)
      
      FormRequest.create!(user: user1, form: form)
      FormRequest.create!(user: user2, form: form)

      expect(form.form_requests.count).to eq(2)
      expect(form.users).to include(user1, user2)
    end
  end

  describe "answers relationship" do
    it "can have multiple answers" do
      form = create(:form, admin: admin, course: course, question_set: question_set)
      
      answer1 = Answer.create!(form: form, data: "Answer 1")
      answer2 = Answer.create!(form: form, data: "Answer 2")

      expect(form.answers.count).to eq(2)
      expect(form.answers).to include(answer1, answer2)
    end
  end
end

require 'rails_helper'

RSpec.describe CreateFormService, type: :service do
  describe '.call' do
    let(:user)   { create(:user) }
    let(:admin)  { create(:admin, user: user) }

    let(:question_set) { create(:question_set) }
    let(:template)     { create(:template, question_set: question_set) }

    let(:course)       { create(:course) }
    let(:student)      { create(:user) }
    let(:teacher)      { create(:user) }

    before do
      course.students << student
      course.update!(teacher: teacher)
    end

    context 'when template and courses are valid' do
      it 'creates a form for each selected course' do
        expect {
          described_class.call(
            admin: admin,
            template_id: template.id,
            course_ids: [course.id]
          )
        }.to change(Form, :count).by(1)
      end

      it 'assigns the form to the correct course and admin' do
        described_class.call(
          admin: admin,
          template_id: template.id,
          course_ids: [course.id]
        )

        form = Form.last
        expect(form.course).to eq(course)
        expect(form.admin).to eq(admin)
        expect(form.question_set).to eq(question_set)
      end

      it 'creates form requests for students and teacher' do
        expect {
          described_class.call(
            admin: admin,
            template_id: template.id,
            course_ids: [course.id]
          )
        }.to change(FormRequest, :count).by(2)

        recipients = FormRequest.last(2).map(&:user)
        expect(recipients).to contain_exactly(student, teacher)
      end
    end

    context 'when template is missing' do
      it 'raises MissingTemplate error' do
        expect {
          described_class.call(
            admin: admin,
            template_id: nil,
            course_ids: [course.id]
          )
        }.to raise_error(CreateFormService::MissingTemplate)
      end
    end

    context 'when no courses are selected' do
      it 'raises MissingCourses error' do
        expect {
          described_class.call(
            admin: admin,
            template_id: template.id,
            course_ids: []
          )
        }.to raise_error(CreateFormService::MissingCourses)
      end
    end

    context 'when course_ids are invalid' do
      it 'raises MissingCourses error' do
        expect {
          described_class.call(
            admin: admin,
            template_id: template.id,
            course_ids: [999_999]
          )
        }.to raise_error(CreateFormService::MissingCourses)
      end
    end
  end
end

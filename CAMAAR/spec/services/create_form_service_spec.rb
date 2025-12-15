require 'rails_helper'

RSpec.describe CreateFormService, type: :service do
  describe '.call' do
    let(:user)  { create(:user) }
    let(:admin) { create(:admin, user: user) }

    let(:question_set) { create(:question_set) }
    let(:template)     { create(:template, question_set: question_set) }

    let(:course)  { create(:course) }
    let(:student) { create(:user) }
    let(:teacher) { create(:user) }

    let(:template_id) { template&.id }
    let(:course_ids)  { [course.id] }

    subject(:call_service) do
      described_class.call(
        admin: admin,
        template_id: template_id,
        course_ids: course_ids
      )
    end

    before do
      course.students << student
      course.update!(teacher: teacher)
    end

    context 'when template and courses are valid' do
      context 'form creation' do
        it 'creates one form' do
          expect { call_service }.to change(Form, :count).by(1)
        end
      end

      context 'created form attributes' do
        before { call_service }

        let(:form) { Form.last }

        it 'assigns the correct course' do
          expect(form.course).to eq(course)
        end

        it 'assigns the correct admin' do
          expect(form.admin).to eq(admin)
        end

        it 'assigns the correct question set' do
          expect(form.question_set).to eq(question_set)
        end
      end

      context 'form requests' do
        it 'creates form requests for all recipients' do
          expect { call_service }
            .to change(FormRequest, :count).by(2)
        end

        it 'assigns requests to student and teacher' do
          call_service

          expect_form_requests_assigned_to(student, teacher)
        end
      end
    end

    context 'when template is missing' do
      let(:template_id) { nil }

      it 'raises MissingTemplate error' do
        expect { call_service }
          .to raise_error(CreateFormService::MissingTemplate)
      end
    end

    context 'when no courses are selected' do
      let(:course_ids) { [] }

      it 'raises MissingCourses error' do
        expect { call_service }
          .to raise_error(CreateFormService::MissingCourses)
      end
    end

    context 'when course_ids are invalid' do
      let(:course_ids) { [999_999] }

      it 'raises MissingCourses error' do
        expect { call_service }
          .to raise_error(CreateFormService::MissingCourses)
      end
    end
  end
end


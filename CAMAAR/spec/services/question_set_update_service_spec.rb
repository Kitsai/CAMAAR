require 'rails_helper'

RSpec.describe QuestionSetUpdateService, type: :service do
  let(:admin) { create_admin_record }
  let(:question_set) { create(:question_set) }
  let(:template) { create(:template, admin: admin, question_set: question_set) }

  let(:new_question_data) do
    [
      { "question" => "Updated question 1?", "type" => "text" },
      { "question" => "Updated question 2?", "type" => "radio", "options" => ["Yes", "No"] }
    ]
  end

  describe '#call' do
    context 'when question_set_data is nil' do
      it 'returns success without making changes' do
        expect_no_changes_to_question_set(template) do
          result = call_update_service(template, nil)
          expect_service_success_only(result)
        end
      end
    end

    context 'when forms exist for the question_set (copy-on-write scenario)' do
      let(:course) { create(:course) }
      let!(:form) { create(:form, admin: admin, course: course, question_set: question_set) }

      it 'creates a new question_set' do
        expect_new_question_set_created(template) do
          expect_question_set_count_increases_by(1) do
            call_update_service(template, new_question_data)
          end
        end
      end

      it 'updates the template to reference the new question_set' do
        call_update_service(template, new_question_data)

        expect_question_set_data_updated(template, new_question_data)
      end

      it 'preserves the old question_set for existing forms' do
        original_question_set = template.question_set
        original_data = original_question_set.data

        call_update_service(template, new_question_data)

        expect_old_question_set_preserved(form, original_question_set, original_data)
      end

      it 'returns success result with updated template' do
        result = call_update_service(template, new_question_data)

        expect_service_success(result, template)
      end

      it 'reloads the template' do
        expect(template).to receive(:reload)
        described_class.new(template, new_question_data).call
      end
    end

    context 'when no forms exist for the question_set' do
      it 'updates the existing question_set in place' do
        expect_no_changes_to_question_set(template) do
          expect_question_set_count_unchanged do
            call_update_service(template, new_question_data)
          end
        end
      end

      it 'updates the question_set data' do
        call_update_service(template, new_question_data)

        expect_question_set_data_updated(template, new_question_data)
      end

      it 'returns success result with updated template' do
        result = call_update_service(template, new_question_data)

        expect_service_success(result, template)
      end

      it 'reloads the template' do
        expect(template).to receive(:reload)
        described_class.new(template, new_question_data).call
      end
    end
  end
end

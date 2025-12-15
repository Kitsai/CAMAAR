require 'rails_helper'

RSpec.describe QuestionSetUpdateService do
  let(:admin_user) { create(:user, :admin) }
  let(:admin) { admin_user.admin }
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
        original_question_set_id = template.question_set_id

        result = described_class.new(template, nil).call

        expect(result[:success]).to be true
        expect(template.question_set_id).to eq(original_question_set_id)
      end
    end

    context 'when forms exist for the question_set (copy-on-write scenario)' do
      let(:course) { create(:course) }
      let!(:form) { create(:form, admin: admin, course: course, question_set: question_set) }

      it 'creates a new question_set' do
        original_question_set_id = template.question_set_id

        expect {
          described_class.new(template, new_question_data).call
        }.to change { QuestionSet.count }.by(1)

        expect(template.question_set_id).not_to eq(original_question_set_id)
      end

      it 'updates the template to reference the new question_set' do
        described_class.new(template, new_question_data).call

        expect(template.question_set.data).to eq(new_question_data)
      end

      it 'preserves the old question_set for existing forms' do
        original_question_set = template.question_set
        original_data = original_question_set.data

        described_class.new(template, new_question_data).call

        # Reload the form and verify it still references the old question_set
        form.reload
        expect(form.question_set_id).to eq(original_question_set.id)
        expect(form.question_set.data).to eq(original_data)
      end

      it 'returns success result with updated template' do
        result = described_class.new(template, new_question_data).call

        expect(result[:success]).to be true
        expect(result[:template]).to eq(template)
      end

      it 'reloads the template' do
        expect(template).to receive(:reload)
        described_class.new(template, new_question_data).call
      end
    end

    context 'when no forms exist for the question_set' do
      it 'updates the existing question_set in place' do
        original_question_set_id = template.question_set_id

        expect {
          described_class.new(template, new_question_data).call
        }.not_to change { QuestionSet.count }

        expect(template.question_set_id).to eq(original_question_set_id)
      end

      it 'updates the question_set data' do
        described_class.new(template, new_question_data).call

        expect(template.question_set.data).to eq(new_question_data)
      end

      it 'returns success result with updated template' do
        result = described_class.new(template, new_question_data).call

        expect(result[:success]).to be true
        expect(result[:template]).to eq(template)
      end

      it 'reloads the template' do
        expect(template).to receive(:reload)
        described_class.new(template, new_question_data).call
      end
    end
  end
end

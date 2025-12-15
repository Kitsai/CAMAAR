require 'rails_helper'

RSpec.describe AnswerStorageService, type: :service do
  let(:admin_user) { create(:user, :admin) }
  let(:admin) { admin_user.admin }
  let(:teacher) { create(:user) }
  let(:course) { create(:course, teacher: teacher) }
  let(:question_set) { create(:question_set) }
  let(:form) { create(:form, admin: admin, course: course, question_set: question_set) }

  describe '#call' do
    context 'with valid array format answers' do
      let(:answers) { build_uniform_answers(form, "Test answer") }

      it 'returns success result' do
        result = call_answer_storage(form, answers)
        expect_answer_storage_success(result)
      end

      it 'creates an answer record' do
        expect_answer_created { call_answer_storage(form, answers) }
      end

      it 'stores data in CSV format' do
        result = call_answer_storage(form, answers)
        expect_answer_data_format(result)
      end

      it 'stores correct answer values' do
        result = call_answer_storage(form, answers)
        expect_answer_values(result, "Test answer")
      end
    end

    context 'with hash format answers' do
      let(:answers_hash) { build_hash_format_answers(form) }

      it 'returns success result' do
        result = call_answer_storage(form, answers_hash)
        expect_answer_storage_success(result)
      end

      it 'creates an answer record' do
        expect_answer_created { call_answer_storage(form, answers_hash) }
      end
    end

    context 'with answers containing commas' do
      let(:answers) { build_answers_with_special_first(form, "Answer with, comma") }

      it 'properly escapes commas' do
        result = call_answer_storage(form, answers)
        expect_first_answer_equals(result, "Answer with, comma")
      end
    end

    context 'with answers containing quotes' do
      let(:answers) { build_answers_with_special_first(form, 'Answer with "quotes"') }

      it 'properly escapes quotes' do
        result = call_answer_storage(form, answers)
        expect_first_answer_equals(result, 'Answer with "quotes"')
      end
    end

    context 'with invalid data' do
      it 'returns error when form is nil' do
        result = call_answer_storage(nil, [])
        expect_answer_storage_error(result, "Formulário não encontrado")
      end

      it 'returns error when answers are blank' do
        result = call_answer_storage(form, nil)
        expect_answer_storage_error(result, "Respostas não fornecidas")
      end

      it 'returns error when answers are incomplete' do
        incomplete_answers = [ { question: "Q1", answer: "" } ]
        result = call_answer_storage(form, incomplete_answers)
        expect_answer_storage_error(result, "Por favor, responda todas as questões obrigatórias")
      end

      it 'returns error when wrong number of answers' do
        wrong_count_answers = [ { question: "Q1", answer: "Answer" } ]
        result = call_answer_storage(form, wrong_count_answers)
        expect(result[:success]).to be false
      end
    end
  end
end

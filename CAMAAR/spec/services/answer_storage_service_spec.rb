require 'rails_helper'

RSpec.describe AnswerStorageService do
  let(:admin_user) { create(:user, :admin) }
  let(:admin) { admin_user.admin }
  let(:teacher) { create(:user) }
  let(:course) { create(:course, teacher: teacher) }
  let(:question_set) { create(:question_set) }
  let(:form) { create(:form, admin: admin, course: course, question_set: question_set) }

  describe '#call' do
    context 'with valid array format answers' do
      let(:answers) do
        form.question_set.data.map do |question|
          { question: question["question"], answer: "Test answer" }
        end
      end

      it 'returns success result' do
        result = described_class.new(form, answers).call
        expect(result[:success]).to be true
      end

      it 'creates an answer record' do
        expect {
          described_class.new(form, answers).call
        }.to change { Answer.count }.by(1)
      end

      it 'stores data in CSV format' do
        result = described_class.new(form, answers).call
        answer = result[:answer]
        expect(answer.data).to be_present
        expect(answer.parsed_data).to be_an(Array)
      end

      it 'stores correct answer values' do
        result = described_class.new(form, answers).call
        answer = result[:answer]
        expect(answer.parsed_data).to all(eq("Test answer"))
      end
    end

    context 'with hash format answers' do
      let(:answers_hash) do
        hash = {}
        form.question_set.data.each_with_index do |question, idx|
          hash[idx.to_s] = { "question" => question["question"], "answer" => "Hash answer #{idx}" }
        end
        ActionController::Parameters.new(hash)
      end

      it 'returns success result' do
        result = described_class.new(form, answers_hash).call
        expect(result[:success]).to be true
      end

      it 'creates an answer record' do
        expect {
          described_class.new(form, answers_hash).call
        }.to change { Answer.count }.by(1)
      end
    end

    context 'with answers containing commas' do
      let(:answers) do
        form.question_set.data.map.with_index do |question, idx|
          if idx == 0
            { question: question["question"], answer: "Answer with, comma" }
          else
            { question: question["question"], answer: "Normal answer" }
          end
        end
      end

      it 'properly escapes commas' do
        result = described_class.new(form, answers).call
        answer = result[:answer]
        
        # Parsing should correctly handle escaped commas
        expect(answer.parsed_data.first).to eq("Answer with, comma")
      end
    end

    context 'with answers containing quotes' do
      let(:answers) do
        form.question_set.data.map.with_index do |question, idx|
          if idx == 0
            { question: question["question"], answer: 'Answer with "quotes"' }
          else
            { question: question["question"], answer: "Normal answer" }
          end
        end
      end

      it 'properly escapes quotes' do
        result = described_class.new(form, answers).call
        answer = result[:answer]
        
        expect(answer.parsed_data.first).to eq('Answer with "quotes"')
      end
    end

    context 'with invalid data' do
      it 'returns error when form is nil' do
        result = described_class.new(nil, []).call
        expect(result[:success]).to be false
        expect(result[:error]).to eq("Formulário não encontrado")
      end

      it 'returns error when answers are blank' do
        result = described_class.new(form, nil).call
        expect(result[:success]).to be false
        expect(result[:error]).to eq("Respostas não fornecidas")
      end

      it 'returns error when answers are incomplete' do
        incomplete_answers = [
          { question: "Q1", answer: "" }
        ]
        result = described_class.new(form, incomplete_answers).call
        expect(result[:success]).to be false
        expect(result[:error]).to eq("Por favor, responda todas as questões obrigatórias")
      end

      it 'returns error when wrong number of answers' do
        wrong_count_answers = [
          { question: "Q1", answer: "Answer" }
        ]
        # Assuming question_set has 2 questions
        result = described_class.new(form, wrong_count_answers).call
        expect(result[:success]).to be false
      end
    end
  end
end

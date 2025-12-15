module AnswerStorageSpecHelpers
  def call_answer_storage(form, answers)
    AnswerStorageService.new(form, answers).call
  end

  def expect_answer_storage_success(result)
    expect(result[:success]).to be true
  end

  def expect_answer_storage_error(result, error_message)
    expect(result[:success]).to be false
    expect(result[:error]).to eq(error_message)
  end

  def expect_answer_created
    expect { yield }.to change { Answer.count }.by(1)
  end

  def expect_answer_data_format(result)
    answer = result[:answer]
    expect(answer.data).to be_present
    expect(answer.parsed_data).to be_an(Array)
  end

  def expect_answer_values(result, expected_values)
    answer = result[:answer]
    if expected_values.is_a?(String)
      expect(answer.parsed_data).to all(eq(expected_values))
    elsif expected_values.is_a?(Array)
      expect(answer.parsed_data).to eq(expected_values)
    end
  end

  def expect_first_answer_equals(result, expected_value)
    answer = result[:answer]
    expect(answer.parsed_data.first).to eq(expected_value)
  end

  def build_uniform_answers(form, answer_text)
    form.question_set.data.map do |question|
      { question: question["question"], answer: answer_text }
    end
  end

  def build_answers_with_special_first(form, special_answer)
    form.question_set.data.map.with_index do |question, idx|
      if idx == 0
        { question: question["question"], answer: special_answer }
      else
        { question: question["question"], answer: "Normal answer" }
      end
    end
  end

  def build_hash_format_answers(form)
    hash = {}
    form.question_set.data.each_with_index do |question, idx|
      hash[idx.to_s] = { "question" => question["question"], "answer" => "Hash answer #{idx}" }
    end
    ActionController::Parameters.new(hash)
  end
end

RSpec.configure do |config|
  config.include AnswerStorageSpecHelpers, type: :service
end

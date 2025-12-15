module AnswerModelHelpers
  def create_answer_with_data(form, data)
    Answer.create!(form: form, data: data)
  end

  def create_csv_answer(form, *values)
    data = CSV.generate_line(values).strip
    create_answer_with_data(form, data)
  end

  def expect_answer_data_equals(answer, expected_data)
    expect(answer.data).to be_present
    expect(answer.data).to eq(expected_data)
  end

  def expect_csv_values(answer, first_value, last_value)
    answers = answer.data.split(",")
    expect(answers.first).to eq(first_value)
    expect(answers.last).to eq(last_value)
  end

  def expect_form_has_answers(form, count, *answers)
    expect(form.answers.count).to eq(count)
    expect(form.answers).to include(*answers)
  end

  def expect_answer_at_indices(answer, *expected_values)
    expected_values.each_with_index do |value, index|
      expect(answer.answer_at(index)).to eq(value)
    end
  end

  def expect_destroyed_with_form(form, answer)
    answer_id = answer.id
    expect { form.destroy }.to change { Answer.count }.by(-1)
    expect(Answer.find_by(id: answer_id)).to be_nil
  end
end

RSpec.configure do |config|
  config.include AnswerModelHelpers, type: :model
end

module QuestionSetUpdateHelpers
  def call_update_service(template, question_data)
    described_class.new(template, question_data).call
  end

  def expect_question_set_created(template, original_id)
    expect(template.question_set_id).not_to eq(original_id)
  end

  def expect_question_set_unchanged(template, original_id)
    expect(template.question_set_id).to eq(original_id)
  end

  def expect_question_set_data_updated(template, expected_data)
    expect(template.question_set.data).to eq(expected_data)
  end

  def expect_old_question_set_preserved(form, original_question_set, original_data)
    form.reload
    expectations = {
      question_set_id: original_question_set.id,
      question_set_data: original_data
    }

    expect(form.question_set_id).to eq(expectations[:question_set_id])
    expect(form.question_set.data).to eq(expectations[:question_set_data])
  end

  def expect_service_success(result, template)
    expect(result[:success]).to be true
    expect(result[:template]).to eq(template)
  end

  def expect_service_success_only(result)
    expect(result[:success]).to be true
  end

  def expect_no_changes_to_question_set(template)
    original_id = template.question_set_id
    yield
    expect(template.question_set_id).to eq(original_id)
  end

  def expect_new_question_set_created(template)
    original_id = template.question_set_id
    yield
    expect_question_set_created(template, original_id)
  end

  def expect_question_set_count_increases_by(count)
    expect { yield }.to change { QuestionSet.count }.by(count)
  end

  def expect_question_set_count_unchanged
    expect { yield }.not_to change { QuestionSet.count }
  end

  def create_admin_record
    create(:user, :admin).admin
  end

  def create_admin_user_and_record
    user = create(:user, :admin)
    { user: user, admin: user.admin }
  end
end

RSpec.configure do |config|
  config.include QuestionSetUpdateHelpers, type: :service
end

module ValidationHelpers
  def verify_belongs_to(model_class, association_name)
    association = model_class.reflect_on_association(association_name)
    expect(association).to be_present
    expect(association.macro).to eq(:belongs_to)
  end

  def verify_has_many(model_class, association_name, options = {})
    association = model_class.reflect_on_association(association_name)
    expect(association).to be_present
    expect(association.macro).to eq(:has_many)
    options.each do |key, value|
      expect(association.options[key]).to eq(value)
    end
  end

  def build_template_with_nested_question_set(admin, name, question_data)
    admin.templates.build(
      name: name,
      question_set_attributes: { data: question_data }
    )
  end

  def expect_template_saved_with_nested_question_set(template, expected_data)
    expect(template.save).to be true
    expect(template.question_set).to be_persisted
    expect(template.question_set.data).to eq(expected_data)
  end

  def expect_question_set_updated_in_place(question_set, expected_data)
    original_id = question_set.id
    yield if block_given?
    question_set.reload
    expect(question_set.id).to eq(original_id)
    expect(question_set.data).to eq(expected_data)
  end
end

RSpec.configure do |config|
  config.include ValidationHelpers, type: :model
end

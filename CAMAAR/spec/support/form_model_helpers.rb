module FormModelHelpers
  def expect_forms_filtered_by(attribute, value, *included_forms, excluded: [])
    filtered = Form.where(attribute => value)
    included_forms.each { |form| expect(filtered).to include(form) }
    excluded.each { |form| expect(filtered).not_to include(form) }
  end

  def create_form_requests_for(form, *users)
    users.each { |user| FormRequest.create!(user: user, form: form) }
  end

  def expect_form_has_requests(form, count, *users)
    expect(form.form_requests.count).to eq(count)
    expect(form.users).to include(*users)
  end

  def create_answers_for(form, *data_values)
    data_values.map { |data| Answer.create!(form: form, data: data) }
  end

  def expect_form_has_answers_count(form, count, *answers)
    expect(form.answers.count).to eq(count)
    expect(form.answers).to include(*answers)
  end

  def expect_has_many_through(model_class, association_name, through:)
    association = model_class.reflect_on_association(association_name)
    expect(association.macro).to eq(:has_many)
    expect(association.options[:through]).to eq(through)
  end
end

RSpec.configure do |config|
  config.include FormModelHelpers, type: :model
end

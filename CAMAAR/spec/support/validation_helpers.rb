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
end

RSpec.configure do |config|
  config.include ValidationHelpers, type: :model
end

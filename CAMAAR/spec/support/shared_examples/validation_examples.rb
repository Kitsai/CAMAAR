RSpec.shared_examples "requires presence of" do |attribute|
  it "requires #{attribute}" do
    subject = build(described_class.name.underscore.to_sym, attribute => nil)
    expect(subject).not_to be_valid
    expect(subject.errors[attribute]).to include("can't be blank")
  end
end

RSpec.shared_examples "requires association" do |association|
  it "requires #{association}" do
    subject = build(described_class.name.underscore.to_sym, association => nil)
    expect(subject).not_to be_valid
    expect(subject.errors[association]).to include("must exist")
  end
end

RSpec.shared_examples "requires unique" do |attribute, factory_name = nil|
  it "requires unique #{attribute}" do
    factory_name ||= described_class.name.underscore.to_sym
    existing = create(factory_name)
    duplicate = build(factory_name, attribute => existing.send(attribute))
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[attribute]).to include("has already been taken")
  end
end

RSpec.shared_examples "fails custom validation" do |attribute, error_message|
  it "fails validation: #{error_message}" do
    expect(subject).not_to be_valid
    expect(subject.errors[attribute]).to include(error_message)
  end
end

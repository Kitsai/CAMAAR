require 'rails_helper'

RSpec.describe ImportData do
  describe "importing data from SIGAA" do
    it "imports valid data" do
      data = [
        { name: "Alice", cpf: "111" },
        { name: "Bob",   cpf: "222" }
      ]

      result = ImportData.run(data)

      expect(result.success_count).to eq(2)
      expect(User.exists?(cpf: "111")).to be(true)
      expect(User.exists?(cpf: "222")).to be(true)
    end

    it "returns zero when no data exists" do
      result = ImportData.run([])

      expect(result.success_count).to eq(0)
    end

    it "fails when format is invalid" do
      data = [{ invalid_key: "??" }]

      result = ImportData.run(data)

      expect(result.error_count).to eq(1)
      expect(result.success_count).to eq(0)
    end

    it "imports only valid entries when some are invalid" do
      data = [
        { name: "Valid", cpf: "111" },
        { name: nil, cpf: "999" }
      ]

      result = ImportData.run(data)

      expect(result.success_count).to eq(1)
      expect(result.error_count).to eq(1)
      expect(User.exists?(cpf: "111")).to be(true)
      expect(User.exists?(cpf: "999")).to be(false)
    end
  end
end
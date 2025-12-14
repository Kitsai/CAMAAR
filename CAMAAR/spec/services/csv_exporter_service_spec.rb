require 'rails_helper'

RSpec.describe CsvExporterService do
  let(:admin_user) { create(:user, :admin) }
  let(:admin) { admin_user.admin }
  let(:teacher) { create(:user) }
  let(:course) { create(:course, code: "CIC0097", teacher: teacher) }
  let(:question_set) { create(:question_set) }
  let(:form) { create(:form, admin: admin, course: course, question_set: question_set) }

  describe '#call' do
    context 'with valid data' do
      before do
        form # Create form
        Answer.create!(form: form, data: CSV.generate_line(["Resposta 1", "Resposta 2"]).strip)
        Answer.create!(form: form, data: CSV.generate_line(["Resposta A", "Resposta B"]).strip)
      end

      it 'returns success result' do
        result = described_class.new(admin, form.id).call
        expect(result[:success]).to be true
      end

      it 'generates CSV data' do
        result = described_class.new(admin, form.id).call
        expect(result[:csv_data]).to be_present
        expect(result[:csv_data]).to include("Formulário")
        expect(result[:csv_data]).to include("Resposta 1")
      end

      it 'generates correct filename' do
        result = described_class.new(admin, form.id).call
        expect(result[:filename]).to match(/CIC0097_form_#{form.id}_\d{8}\.csv/)
      end

      it 'includes all answers' do
        result = described_class.new(admin, form.id).call
        expect(result[:csv_data]).to include("Resposta 1")
        expect(result[:csv_data]).to include("Resposta 2")
        expect(result[:csv_data]).to include("Resposta A")
        expect(result[:csv_data]).to include("Resposta B")
      end
    end

    context 'with invalid data' do
      it 'returns error when admin is nil' do
        result = described_class.new(nil, form.id).call
        expect(result[:success]).to be false
        expect(result[:error]).to eq("Admin não encontrado")
      end

      it 'returns error when form_id is blank' do
        result = described_class.new(admin, nil).call
        expect(result[:success]).to be false
        expect(result[:error]).to eq("ID do formulário não fornecido")
      end

      it 'returns error when admin has no access to form' do
        result = described_class.new(admin, 99999).call
        expect(result[:success]).to be false
        expect(result[:error]).to eq("Você não tem permissão para acessar este formulário")
      end
    end

    context 'with answers containing special characters' do
      before do
        form
        Answer.create!(form: form, data: CSV.generate_line(["Resposta com, vírgula", "Resposta com \"aspas\""]).strip)
      end

      it 'properly escapes special characters' do
        result = described_class.new(admin, form.id).call
        expect(result[:success]).to be true
        # CSV escapes quotes by doubling them
        expect(result[:csv_data]).to include("Resposta com, vírgula")
        expect(result[:csv_data]).to include('""aspas""') # CSV standard escaping
      end
    end
  end
end

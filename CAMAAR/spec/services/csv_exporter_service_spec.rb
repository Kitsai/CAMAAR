require 'rails_helper'

RSpec.describe CsvExporterService, type: :service do
  let(:admin_user) { create(:user, :admin) }
  let(:admin) { admin_user.admin }
  let(:teacher) { create(:user) }
  let(:course) { create(:course, code: "CIC0097", teacher: teacher) }
  let(:question_set) { create(:question_set) }
  let(:form) { create(:form, admin: admin, course: course, question_set: question_set) }

  describe '#call' do
    context 'with valid data' do
      subject(:result) { described_class.new(admin, form.id).call }

      before do
        form # Create form
        Answer.create!(form: form, data: CSV.generate_line(["Resposta 1", "Resposta 2"]).strip)
        Answer.create!(form: form, data: CSV.generate_line(["Resposta A", "Resposta B"]).strip)
      end

      it 'returns success result' do
        expect_successful_csv_export(result)
      end

      it 'generates CSV data with question headers' do
        expect_csv_headers(result[:csv_data], form.question_set.data)
      end

      it 'generates correct filename' do
        expect(result[:filename]).to match(/CIC0097_form_#{form.id}_\d{8}\.csv/)
      end

      it 'includes all answer data' do
        expect_csv_contains_answers(result[:csv_data],
          "Resposta 1", "Resposta 2", "Resposta A", "Resposta B")
      end
    end

    context 'with invalid data' do
      it 'returns error when admin is nil' do
        result = call_csv_exporter(nil, form.id)
        expect_csv_export_error(result, "Admin não encontrado")
      end

      it 'returns error when form_id is blank' do
        result = call_csv_exporter(admin, nil)
        expect_csv_export_error(result, "ID do formulário não fornecido")
      end

      it 'returns error when admin has no access to form' do
        result = call_csv_exporter(admin, 99999)
        expect_csv_export_error(result, "Você não tem permissão para acessar este formulário")
      end
    end

    context 'with answers containing special characters' do
      before do
        form
        Answer.create!(form: form, data: CSV.generate_line(["Resposta com, vírgula", "Resposta com \"aspas\""]).strip)
      end

      it 'properly escapes special characters' do
        result = call_csv_exporter(admin, form.id)
        expect(result[:success]).to be true
        # CSV escapes quotes by doubling them
        expect_csv_escapes_special_chars(result[:csv_data], "Resposta com, vírgula", '""aspas""')
      end
    end
  end
end

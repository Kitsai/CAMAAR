require "rails_helper"

RSpec.describe "Forms", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:admin) { admin_user.admin }

  let(:course) { create(:course) }
  let(:student) { create(:user) }
  let(:teacher) { create(:user) }

  let(:question_set) { create(:question_set, data: [{ question: "Q1" }]) }
  let(:template) { create(:template, admin: admin, question_set: question_set) }

  before do
    # login (same pattern as templates_spec)
    post login_path, params: {
      email: admin_user.email,
      password: "password123"
    }

    # course recipients (required by CreateFormService)
    course.students << student
    course.update!(teacher: teacher)
  end

  describe "POST /forms" do
    let(:template) { create(:template, admin: admin) }
    let(:class_a) { create(:course) }
    let(:class_b) { create(:course) }

    before do
      post login_path, params: { email: admin_user.email, password: "password123" }
    end

    context "when form is created successfully" do
      it "creates a form" do
        expect {
          post "/forms", params: {
            template_id: template.id,
            course_ids: [course.id]
          }
        }.to change(Form, :count).by(1)
      end

      it "creates form requests for students and teacher" do
        expect {
          post "/forms", params: {
            template_id: template.id,
            course_ids: [course.id]
          }
        }.to change(FormRequest, :count).by(2)
      end

      it "redirects to forms index" do
        post "/forms", params: {
          template_id: template.id,
          course_ids: [course.id]
        }

        expect(response).to redirect_to(forms_path)
      end

      it "shows success message" do
        post "/forms", params: {
          template_id: template.id,
          course_ids: [course.id]
        }

        follow_redirect!
        expect(response.body).to include("Formulários criados com sucesso!")
      end
    end

    context "when no template is selected" do
      it "does not create a form" do
        expect {
          post "/forms", params: {
            template_id: nil,
            course_ids: [course.id]
          }
        }.not_to change(Form, :count)
      end

      it "redirects with error message" do
        post "/forms", params: {
          template_id: nil,
          course_ids: [course.id]
        }

        expect(response).to redirect_to(forms_path)
        follow_redirect!
        expect(response.body).to include("É necessário selecionar um template")
      end
    end

    context "when no courses are selected" do
      it "does not create a form" do
        expect {
          post "/forms", params: {
            template_id: template.id,
            course_ids: []
          }
        }.not_to change(Form, :count)
      end

      it "redirects with error message" do
        post "/forms", params: {
          template_id: template.id,
          course_ids: []
        }

        expect(response).to redirect_to(forms_path)
        follow_redirect!
        expect(response.body).to include("É necessário selecionar pelo menos uma turma")
      end
    end
  end
end

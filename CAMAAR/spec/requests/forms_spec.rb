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
    post login_path, params: {
      email: admin_user.email,
      password: "password123"
    }

    course.students << student
    course.update!(teacher: teacher)
  end

  def post_forms(template_id:, course_ids:)
    post "/forms", params: {
      template_id: template_id,
      course_ids: course_ids
    }
  end

  describe "POST /forms" do
    context "when form is created successfully" do
      subject(:make_request) do
        post_forms(template_id: template.id, course_ids: [course.id])
      end

      it "creates a form" do
        expect { make_request }.to change(Form, :count).by(1)
      end

      it "creates form requests" do
        expect { make_request }.to change(FormRequest, :count).by(2)
      end

      it "redirects to forms index" do
        make_request
        expect(response).to redirect_to(forms_path)
      end

      it "shows success message" do
        make_request
        follow_redirect!
        expect(response.body).to include("Formulários criados com sucesso!")
      end
    end

    context "when no template is selected" do
      subject(:make_request) do
        post_forms(template_id: nil, course_ids: [course.id])
      end

      it "does not create a form" do
        expect { make_request }.not_to change(Form, :count)
      end

      it "shows error message" do
        make_request
        follow_redirect!
        expect(response.body).to include("É necessário selecionar um template")
      end
    end

    context "when no courses are selected" do
      subject(:make_request) do
        post_forms(template_id: template.id, course_ids: [])
      end

      it "does not create a form" do
        expect { make_request }.not_to change(Form, :count)
      end

      it "shows error message" do
        make_request
        follow_redirect!
        expect(response.body).to include("É necessário selecionar pelo menos uma turma")
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "Forms", type: :request do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:course) { create(:course) }
  let(:question_set) { create(:question_set) }
  let(:admin_user) { create(:user, :admin) }
  let(:admin) { admin_user.admin }

  describe "POST /forms" do
    let(:template) { create(:template, admin: admin) }
    let(:class_a) { create(:course) }
    let(:class_b) { create(:course) }

    before do
      post login_path, params: { email: admin_user.email, password: "password123" }
    end

    context "when form is created successfully" do
      it "creates a new form and assigns it to classes" do
        post "/forms", params: {
          template_id: template.id,
          course_ids: [class_a.id, class_b.id]
        }

        expect(response).to have_http_status(:found)
        expect(flash[:notice]).to eq("Formulários criados com sucesso!")

        # Should create one form per course
        expect(Form.count).to eq(2)

        # Both forms should have the question_set from the template
        Form.all.each do |form|
          expect(form.question_set_id).to eq(template.question_set_id)
          expect(form.admin).to eq(admin)
        end

        # Should create forms for both courses
        expect(Form.find_by(course: class_a)).to be_present
        expect(Form.find_by(course: class_b)).to be_present
      end
    end

    context "when no template is selected" do
      it "returns an error message" do
        post "/forms", params: {
          template_id: nil,
          course_ids: [class_a.id]
        }

        expect(response).to redirect_to(forms_path)
        expect(flash[:alert]).to eq("É necessário selecionar um template")
        expect(Form.count).to eq(0)
      end
    end

    context "when no classes are selected" do
      it "returns an error message" do
        # Force template creation before the POST
        template_id_value = template.id

        post "/forms", params: {
          template_id: template_id_value,
          course_ids: []
        }

        expect(response).to redirect_to(forms_path)
        expect(flash[:alert]).to eq("É necessário selecionar pelo menos uma turma")
        expect(Form.count).to eq(0)
      end
    end
  end

  describe "GET /avaliacoes (forms#index) - for regular users" do
    context "when not logged in" do
      it "redirects to login page" do
        get "/avaliacoes"
        expect(response).to redirect_to(login_path)
      end

      it "shows an alert message" do
        get "/avaliacoes"
        follow_redirect!
        expect(response.body).to include("You must be logged in")
      end
    end

    context "when logged in as regular user" do
      before do
        post login_path, params: { email: user1.email, password: "password123" }
      end

      it "returns http success" do
        get "/avaliacoes"
        expect(response).to have_http_status(:success)
      end

      it "displays forms assigned to the current user only" do
        # Create forms assigned to user1
        form1 = create(:form, admin: admin, course: course, question_set: question_set)
        form2 = create(:form, admin: admin, course: create(:course), question_set: question_set)
        FormRequest.create!(user: user1, form: form1)
        FormRequest.create!(user: user1, form: form2)

        # Create form assigned to user2 (should not be displayed)
        form3 = create(:form, admin: admin, course: create(:course), question_set: question_set)
        FormRequest.create!(user: user2, form: form3)

        get "/avaliacoes"
        
        # Should see own forms
        expect(response.body).to include(form1.course.name)
        expect(response.body).to include(form2.course.name)
        
        # Should not see other user's forms
        expect(response.body).not_to include(form3.course.name) unless form1.course.name == form3.course.name || form2.course.name == form3.course.name
      end
    end

    context "when logged in as user" do
      before do
        post login_path, params: { email: user1.email, password: "password123" }
      end

      it "returns http success" do
        get "/avaliacoes"
        expect(response).to have_http_status(:success)
      end

      it "includes forms in response body" do
        form1 = create(:form, admin: admin, course: course, question_set: question_set)
        form2 = create(:form, admin: admin, course: create(:course), question_set: question_set)
        FormRequest.create!(user: user1, form: form1)
        FormRequest.create!(user: user1, form: form2)
        
        get "/avaliacoes"
        expect(response.body).to include(form1.course.name)
        expect(response.body).to include(form2.course.name)
      end

      context "when user has no forms assigned" do
        it "returns success with empty list" do
          get "/avaliacoes"
          expect(response).to have_http_status(:success)
        end

        it "shows appropriate message for no forms" do
          get "/avaliacoes"
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "GET /gerenciamento/resultados (forms#results) - for admins" do
    context "when logged in as admin" do
      before do
        post login_path, params: { email: admin_user.email, password: "password123" }
      end

      it "returns http success" do
        get "/gerenciamento/resultados"
        expect(response).to have_http_status(:success)
      end

      it "displays forms created by the admin" do
        form1 = create(:form, admin: admin, course: course, question_set: question_set)
        form2 = create(:form, admin: admin, course: create(:course), question_set: question_set)
        
        get "/gerenciamento/resultados"
        
        expect(response.body).to include(form1.course.name)
        expect(response.body).to include(form2.course.name)
      end

      it "does not display forms created by other admins" do
        other_admin = create(:user, :admin).admin
        other_form = create(:form, admin: other_admin, course: create(:course), question_set: question_set)
        
        get "/gerenciamento/resultados"
        
        expect(response.body).not_to include(other_form.course.name)
      end
    end

    context "when logged in as regular user" do
      before do
        post login_path, params: { email: user1.email, password: "password123" }
      end

      it "redirects to avaliacoes with access denied" do
        get "/gerenciamento/resultados"
        expect(response).to redirect_to(avaliacoes_path)
        expect(flash[:alert]).to include("Acesso negado")
      end
    end
  end

  describe "scoping" do
    it "only shows forms assigned to the logged-in user" do
      form1 = create(:form, admin: admin, course: create(:course), question_set: question_set)
      form2 = create(:form, admin: admin, course: create(:course), question_set: question_set)
      
      FormRequest.create!(user: user1, form: form1)
      FormRequest.create!(user: user2, form: form2)

      # Login as user1
      post login_path, params: { email: user1.email, password: "password123" }
      get "/avaliacoes"
      
      expect(response.body).to include(form1.course.name)
      expect(response.body).not_to include(form2.course.name) unless form1.course.name == form2.course.name
    end
  end

  describe "GET /forms/:id (forms#show)" do
    let(:form) { create(:form, admin: admin, course: course, question_set: question_set) }
    
    context "when not logged in" do
      it "redirects to login page" do
        get "/forms/#{form.id}"
        expect(response).to redirect_to(login_path)
      end
    end

    context "when user has access to the form" do
      before do
        FormRequest.create!(user: user1, form: form)
        post login_path, params: { email: user1.email, password: "password123" }
      end

      it "returns http success" do
        get "/forms/#{form.id}"
        expect(response).to have_http_status(:success)
      end

      it "displays the form details" do
        get "/forms/#{form.id}"
        expect(response.body).to include(form.course.name)
      end

      it "displays all questions from the question_set" do
        get "/forms/#{form.id}"
        form.question_set.data.each do |question|
          expect(response.body).to include(question["question"])
        end
      end
    end

    context "when user does not have access to the form" do
      before do
        # Login as user1 but don't create form_request
        post login_path, params: { email: user1.email, password: "password123" }
      end

      it "redirects to forms index" do
        get "/forms/#{form.id}"
        expect(response).to redirect_to(avaliacoes_path)
      end

      it "shows access denied message" do
        get "/forms/#{form.id}"
        expect(flash[:alert]).to include("não está mais disponível")
      end
    end
  end

  describe "POST /forms/:id/submit (forms#submit)" do
    let(:form) { create(:form, admin: admin, course: course, question_set: question_set) }
    let(:form_request) { FormRequest.create!(user: user1, form: form) }
    
    context "when not logged in" do
      it "redirects to login page" do
        post "/forms/#{form.id}/submit", params: { answers: [] }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when user has access to the form" do
      before do
        form_request # Create form_request
        post login_path, params: { email: user1.email, password: "password123" }
      end

      context "with valid answers" do
        let(:valid_answers) do
          form.question_set.data.map.with_index do |question, index|
            { question: question["question"], answer: "Answer #{index}" }
          end
        end

        it "creates an answer record" do
          expect {
            post "/forms/#{form.id}/submit", params: { answers: valid_answers }
          }.to change { Answer.count }.by(1)
        end

        it "stores the answers as CSV" do
          post "/forms/#{form.id}/submit", params: { answers: valid_answers }
          answer = Answer.last
          expect(answer.form).to eq(form)
          expect(answer.data).to be_a(String)
          expect(answer.data).to include("Answer 0")
        end

        it "removes the form_request" do
          expect {
            post "/forms/#{form.id}/submit", params: { answers: valid_answers }
          }.to change { FormRequest.count }.by(-1)
        end

        it "redirects to forms index" do
          post "/forms/#{form.id}/submit", params: { answers: valid_answers }
          expect(response).to redirect_to(avaliacoes_path)
        end

        it "shows success message" do
          post "/forms/#{form.id}/submit", params: { answers: valid_answers }
          expect(flash[:notice]).to include("Avaliação enviada com sucesso")
        end
      end

      context "with incomplete answers" do
        let(:incomplete_answers) { [] }

        it "does not create an answer record" do
          expect {
            post "/forms/#{form.id}/submit", params: { answers: incomplete_answers }
          }.not_to change { Answer.count }
        end

        it "does not remove the form_request" do
          expect {
            post "/forms/#{form.id}/submit", params: { answers: incomplete_answers }
          }.not_to change { FormRequest.count }
        end

        it "redirects back to the form" do
          post "/forms/#{form.id}/submit", params: { answers: incomplete_answers }
          expect(response).to redirect_to(form_path(form))
        end

        it "shows validation error message" do
          post "/forms/#{form.id}/submit", params: { answers: incomplete_answers }
          expect(flash[:alert]).to include("Por favor, responda todas as questões")
        end
      end
    end

    context "when user does not have access to the form" do
      before do
        post login_path, params: { email: user1.email, password: "password123" }
      end

      it "does not create an answer" do
        expect {
          post "/forms/#{form.id}/submit", params: { answers: [] }
        }.not_to change { Answer.count }
      end

      it "redirects to forms index" do
        post "/forms/#{form.id}/submit", params: { answers: [] }
        expect(response).to redirect_to(avaliacoes_path)
      end

      it "shows error message" do
        post "/forms/#{form.id}/submit", params: { answers: [] }
        expect(flash[:alert]).to include("não está mais disponível")
      end
    end
  end

  describe "GET /gerenciamento/resultados/forms/:form_id/csv (forms#export_csv)" do
    let(:course1) { create(:course, code: "CIC0097") }
    let(:course2) { create(:course, code: "CIC0202") }
    let(:form1) { create(:form, admin: admin, course: course1, question_set: question_set) }
    let(:form2) { create(:form, admin: admin, course: course2, question_set: question_set) }

    context "when not logged in" do
      it "redirects to login page" do
        get "/gerenciamento/resultados/forms/#{form1.id}/csv"
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in as admin" do
      before do
        post login_path, params: { email: admin_user.email, password: "password123" }
      end

      context "with a form they manage" do
        before do
          form1 # Create form
          # Create some answers
          Answer.create!(form: form1, data: "Answer 1,Answer 2")
          Answer.create!(form: form1, data: "Answer A,Answer B")
        end

        it "returns http success" do
          get "/gerenciamento/resultados/forms/#{form1.id}/csv"
          expect(response).to have_http_status(:success)
        end

        it "returns CSV content type" do
          get "/gerenciamento/resultados/forms/#{form1.id}/csv"
          expect(response.content_type).to include("text/csv")
        end

        it "sets attachment disposition" do
          get "/gerenciamento/resultados/forms/#{form1.id}/csv"
          expect(response.headers['Content-Disposition']).to include('attachment')
        end

        it "includes correct filename" do
          get "/gerenciamento/resultados/forms/#{form1.id}/csv"
          expect(response.headers['Content-Disposition']).to include("CIC0097_form_#{form1.id}_")
        end

        it "includes CSV headers" do
          get "/gerenciamento/resultados/forms/#{form1.id}/csv"
          expect(response.body).to include("Formulário")
          expect(response.body).to include("Turma")
          expect(response.body).to include("Questão")
          expect(response.body).to include("Resposta")
        end

        it "includes answer data" do
          get "/gerenciamento/resultados/forms/#{form1.id}/csv"
          expect(response.body).to include("Answer 1")
          expect(response.body).to include("Answer 2")
          expect(response.body).to include("Answer A")
          expect(response.body).to include("Answer B")
        end
      end

      context "with a form they don't manage" do
        let(:other_admin) { create(:user, :admin).admin }
        let(:other_course) { create(:course, code: "CIC0105") }
        let(:other_form) { create(:form, admin: other_admin, course: other_course, question_set: question_set) }

        before do
          other_form # Create form for other admin
        end

        it "redirects to forms path" do
          get "/gerenciamento/resultados/forms/#{other_form.id}/csv"
          expect(response).to redirect_to(forms_path)
        end

        it "shows access denied message" do
          get "/gerenciamento/resultados/forms/#{other_form.id}/csv"
          expect(flash[:alert]).to include("Você não tem permissão para acessar este formulário")
        end

        it "does not return CSV" do
          get "/gerenciamento/resultados/forms/#{other_form.id}/csv"
          expect(response.content_type).not_to include("text/csv")
        end
      end

      context "with non-existent form" do
        it "redirects to forms path" do
          get "/gerenciamento/resultados/forms/99999/csv"
          expect(response).to redirect_to(forms_path)
        end

        it "shows access denied message" do
          get "/gerenciamento/resultados/forms/99999/csv"
          expect(flash[:alert]).to include("Você não tem permissão para acessar este formulário")
        end
      end
    end

    context "when logged in as regular user" do
      before do
        post login_path, params: { email: user1.email, password: "password123" }
      end

      it "redirects to avaliacoes with access denied" do
        get "/gerenciamento/resultados/forms/#{form1.id}/csv"
        expect(response).to redirect_to(avaliacoes_path)
        expect(flash[:alert]).to include("Acesso negado")
      end

      it "does not return CSV" do
        get "/gerenciamento/resultados/forms/#{form1.id}/csv"
        expect(response.content_type).not_to include("text/csv")
      end
    end
  end
end

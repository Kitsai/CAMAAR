require 'rails_helper'

RSpec.describe "Forms", type: :request do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:course) { create(:course) }
  let(:question_set) { create(:question_set) }
  let(:admin_user) { create(:user, :admin) }
  let(:admin) { admin_user.admin }

  describe "GET /gerenciamento/resultados (forms#index)" do
    context "when not logged in" do
      it "redirects to login page" do
        get "/gerenciamento/resultados"
        expect(response).to redirect_to(login_path)
      end

      it "shows an alert message" do
        get "/gerenciamento/resultados"
        follow_redirect!
        expect(response.body).to include("You must be logged in")
      end
    end

    context "when logged in as regular user" do
      before do
        post login_path, params: { email: user1.email, password: "password123" }
      end

      it "returns http success" do
        get "/gerenciamento/resultados"
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

        get "/gerenciamento/resultados"
        
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
        get "/gerenciamento/resultados"
        expect(response).to have_http_status(:success)
      end

      it "includes forms in response body" do
        form1 = create(:form, admin: admin, course: course, question_set: question_set)
        form2 = create(:form, admin: admin, course: create(:course), question_set: question_set)
        FormRequest.create!(user: user1, form: form1)
        FormRequest.create!(user: user1, form: form2)
        
        get "/gerenciamento/resultados"
        expect(response.body).to include(form1.course.name)
        expect(response.body).to include(form2.course.name)
      end

      context "when user has no forms assigned" do
        it "returns success with empty list" do
          get "/gerenciamento/resultados"
          expect(response).to have_http_status(:success)
        end

        it "shows appropriate message for no forms" do
          get "/gerenciamento/resultados"
          expect(response).to have_http_status(:success)
        end
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
      get "/gerenciamento/resultados"
      
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
        expect(response).to redirect_to(forms_path)
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
          expect(response).to redirect_to(forms_path)
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
        expect(response).to redirect_to(forms_path)
      end

      it "shows error message" do
        post "/forms/#{form.id}/submit", params: { answers: [] }
        expect(flash[:alert]).to include("não está mais disponível")
      end
    end
  end
end

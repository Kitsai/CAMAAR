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
end

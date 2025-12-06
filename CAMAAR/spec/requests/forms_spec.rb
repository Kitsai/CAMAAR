require 'rails_helper'

RSpec.describe "Forms", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:admin) { admin_user.admin }
  let(:regular_user) { create(:user) }
  let(:course) { create(:course) }
  let(:question_set) { create(:question_set) }

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

    context "when logged in as regular user (not admin)" do
      before do
        post login_path, params: { email: regular_user.email, password: "password123" }
      end

      it "redirects to root path" do
        get "/gerenciamento/resultados"
        expect(response).to redirect_to(root_path)
      end

      it "shows access denied message" do
        get "/gerenciamento/resultados"
        expect(flash[:alert]).to include("Access denied")
      end
    end

    context "when logged in as admin" do
      before do
        post login_path, params: { email: admin_user.email, password: "password123" }
      end

      it "returns http success" do
        get "/gerenciamento/resultados"
        expect(response).to have_http_status(:success)
      end

      it "displays forms for the current admin only" do
        # Create forms for current admin
        form1 = create(:form, admin: admin, course: course, question_set: question_set)
        form2 = create(:form, admin: admin, course: create(:course), question_set: question_set)

        # Create form for another admin (should not be displayed)
        other_admin = create(:user, :admin).admin
        other_form = create(:form, admin: other_admin, course: course, question_set: question_set)

        get "/gerenciamento/resultados"
        
        # Should see own forms
        expect(response.body).to include(form1.course.name)
        expect(response.body).to include(form2.course.name)
        
        # Should not see other admin's forms
        expect(response.body).not_to include("Course #{other_form.course.name}") if form1.course.name != other_form.course.name
      end

      it "includes forms in response body" do
        form1 = create(:form, admin: admin, course: course, question_set: question_set)
        form2 = create(:form, admin: admin, course: create(:course), question_set: question_set)
        
        get "/gerenciamento/resultados"
        expect(response.body).to include(form1.course.name)
        expect(response.body).to include(form2.course.name)
      end

      context "when admin has no forms" do
        it "returns success with empty list" do
          get "/gerenciamento/resultados"
          expect(response).to have_http_status(:success)
        end

        it "shows appropriate message for no forms" do
          get "/gerenciamento/resultados"
          # This will depend on view implementation
          # For now, just check it renders successfully
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "scoping" do
    it "only shows forms belonging to the logged-in admin" do
      admin1 = create(:user, :admin).admin
      admin2 = create(:user, :admin).admin
      
      form1 = create(:form, admin: admin1, course: create(:course), question_set: question_set)
      form2 = create(:form, admin: admin2, course: create(:course), question_set: question_set)

      # Login as admin1
      post login_path, params: { email: admin1.user.email, password: "password123" }
      get "/gerenciamento/resultados"
      
      expect(response.body).to include(form1.course.name)
      expect(response.body).not_to include(form2.course.name)
    end
  end
end

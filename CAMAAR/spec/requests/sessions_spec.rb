require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  # Helper methods to reduce duplication
  def perform_login(user_param)
    post login_path, params: {
      email: user_param.email,
      password: "password123"
    }
  end

  def perform_invalid_login(email, password)
    post login_path, params: {
      email: email,
      password: password
    }
  end

  describe "GET /login" do
    it "returns http success" do
      get login_path
      expect(response).to have_http_status(:success)
    end

    it "renders the login form" do
      get login_path
      expect(response.body).to include('form')
    end
  end

  describe "POST /login" do
    context "with valid credentials" do
      before { perform_login(user) }

      it "logs in the user" do
        expect(session[:user_id]).to eq(user.id)
      end

      it "redirects to avaliacoes path for regular users" do
        expect(response).to redirect_to(avaliacoes_path)
      end

      it "shows success message" do
        follow_redirect!
        expect(response.body).to include("Successfully logged in")
      end
    end

    context "with invalid email" do
      before { perform_invalid_login("nonexistent@example.com", "password123") }

      it "does not log in the user" do
        expect(session[:user_id]).to be_nil
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "shows error message" do
        expect(response.body).to include("Invalid email or password")
      end
    end

    context "with invalid password" do
      before { perform_invalid_login(user.email, "wrongpassword") }

      it "does not log in the user" do
        expect(session[:user_id]).to be_nil
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "shows error message" do
        expect(response.body).to include("Invalid email or password")
      end
    end
  end

  describe "DELETE /logout" do
    before do
      post login_path, params: {
        email: user.email,
        password: "password123"
      }
    end

    it "logs out the user" do
      delete logout_path
      expect(session[:user_id]).to be_nil
    end

    it "redirects to root path" do
      delete logout_path
      expect(response).to redirect_to(root_path)
    end

    it "shows success message" do
      delete logout_path
      follow_redirect!
      expect(response.body).to include("Successfully logged out")
    end
  end

  describe "Admin user authentication" do
    let(:admin_user) { create(:user, :admin) }

    before { perform_login(admin_user) }

    it "shows gerenciamento menu after login" do
      follow_redirect!
      expect(response.body).to include("Gerenciamento")
    end

    it "redirects admin to avaliacoes path after login" do
      expect(response).to redirect_to(avaliacoes_path)
    end
  end

  describe "GET /login when already logged in" do
    context "as regular user" do
      let(:user) { create(:user) }

      before do
        perform_login(user)
        get login_path
      end

      it "redirects to avaliacoes path" do
        expect(response).to redirect_to(avaliacoes_path)
      end

      it "shows already logged in message" do
        follow_redirect!
        expect(response.body).to include("You are already logged in")
      end
    end

    context "as admin user" do
      let(:admin_user) { create(:user, :admin) }

      before do
        perform_login(admin_user)
        get login_path
      end

      it "redirects to forms path" do
        expect(response).to redirect_to(forms_path)
      end

      it "shows already logged in message" do
        follow_redirect!
        expect(response.body).to include("You are already logged in")
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

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
      it "logs in the user" do
        post login_path, params: {
          email: user.email,
          password: "password123"
        }
        expect(session[:user_id]).to eq(user.id)
      end

      it "redirects to avaliacoes path for regular users" do
        post login_path, params: {
          email: user.email,
          password: "password123"
        }
        expect(response).to redirect_to(avaliacoes_path)
      end

      it "shows success message" do
        post login_path, params: {
          email: user.email,
          password: "password123"
        }
        follow_redirect!
        expect(response.body).to include("Successfully logged in")
      end
    end

    context "with invalid email" do
      it "does not log in the user" do
        post login_path, params: {
          email: "nonexistent@example.com",
          password: "password123"
        }
        expect(session[:user_id]).to be_nil
      end

      it "returns unprocessable entity status" do
        post login_path, params: {
          email: "nonexistent@example.com",
          password: "password123"
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "shows error message" do
        post login_path, params: {
          email: "nonexistent@example.com",
          password: "password123"
        }
        expect(response.body).to include("Invalid email or password")
      end
    end

    context "with invalid password" do
      it "does not log in the user" do
        post login_path, params: {
          email: user.email,
          password: "wrongpassword"
        }
        expect(session[:user_id]).to be_nil
      end

      it "returns unprocessable entity status" do
        post login_path, params: {
          email: user.email,
          password: "wrongpassword"
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "shows error message" do
        post login_path, params: {
          email: user.email,
          password: "wrongpassword"
        }
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

    it "shows gerenciamento menu after login" do
      post login_path, params: {
        email: admin_user.email,
        password: "password123"
      }
      follow_redirect!
      expect(response.body).to include("Gerenciamento")
    end

    it "redirects admin to avaliacoes path after login" do
      post login_path, params: {
        email: admin_user.email,
        password: "password123"
      }
      expect(response).to redirect_to(avaliacoes_path)
    end
  end

  describe "GET /login when already logged in" do
    context "as regular user" do
      let(:user) { create(:user) }

      it "redirects to avaliacoes path" do
        post login_path, params: {
          email: user.email,
          password: "password123"
        }
        get login_path
        expect(response).to redirect_to(avaliacoes_path)
      end

      it "shows already logged in message" do
        post login_path, params: {
          email: user.email,
          password: "password123"
        }
        get login_path
        follow_redirect!
        expect(response.body).to include("You are already logged in")
      end
    end

    context "as admin user" do
      let(:admin_user) { create(:user, :admin) }

      it "redirects to forms path" do
        post login_path, params: {
          email: admin_user.email,
          password: "password123"
        }
        get login_path
        expect(response).to redirect_to(forms_path)
      end

      it "shows already logged in message" do
        post login_path, params: {
          email: admin_user.email,
          password: "password123"
        }
        get login_path
        follow_redirect!
        expect(response.body).to include("You are already logged in")
      end
    end
  end
end

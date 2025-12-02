require 'rails_helper'

RSpec.describe "Passwords", type: :request do
  describe "GET /set_password" do
    context "when user has no password" do
      let(:user) { User.create!(email: "newuser@example.com") }

      it "returns http success" do
        get set_password_path(email: user.email)
        expect(response).to have_http_status(:success)
      end

      it "renders the password setup form" do
        get set_password_path(email: user.email)
        expect(response.body).to include('form')
        expect(response.body).to include('Senha')
        expect(response.body).to include('Confirmar')
      end
    end

    context "when user already has a password" do
      let(:user) { create(:user) }

      it "redirects to login page" do
        get set_password_path(email: user.email)
        expect(response).to redirect_to(login_path)
      end

      it "shows error message" do
        get set_password_path(email: user.email)
        follow_redirect!
        expect(response.body).to include("Password already registered")
      end
    end
  end

  describe "POST /set_password" do
    let(:user) { User.create!(email: "newuser@example.com") }

    context "with matching passwords" do
      let(:valid_params) do
        {
          email: user.email,
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      end

      it "sets the user password" do
        post set_password_path, params: valid_params
        user.reload
        expect(user.password_digest).not_to be_nil
      end

      it "allows login with new password" do
        post set_password_path, params: valid_params
        user.reload
        expect(user.authenticate("newpassword123")).to eq(user)
      end

      it "redirects to login page" do
        post set_password_path, params: valid_params
        expect(response).to redirect_to(login_path)
      end

      it "shows success message" do
        post set_password_path, params: valid_params
        follow_redirect!
        expect(response.body).to include("Passwords set successfully")
      end
    end

    context "with mismatched passwords" do
      let(:invalid_params) do
        {
          email: user.email,
          password: "newpassword123",
          password_confirmation: "differentpassword"
        }
      end

      it "does not set the password" do
        post set_password_path, params: invalid_params
        user.reload
        expect(user.password_digest).to be_nil
      end

      it "returns unprocessable entity status" do
        post set_password_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "shows error message" do
        post set_password_path, params: invalid_params
        expect(response.body).to include("Passwords do not match")
      end
    end

    context "when user not found" do
      let(:invalid_params) do
        {
          email: "nonexistent@example.com",
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      end

      it "returns unprocessable entity status" do
        post set_password_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "shows error message" do
        post set_password_path, params: invalid_params
        expect(response.body).to include("User not found")
      end
    end

    context "when user already has a password" do
      let(:existing_user) { create(:user) }
      let(:params) do
        {
          email: existing_user.email,
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      end

      it "does not change the password" do
        original_password_digest = existing_user.password_digest
        post set_password_path, params: params
        existing_user.reload
        expect(existing_user.password_digest).to eq(original_password_digest)
      end

      it "redirects to login page" do
        post set_password_path, params: params
        expect(response).to redirect_to(login_path)
      end

      it "shows error message" do
        post set_password_path, params: params
        follow_redirect!
        expect(response.body).to include("Password already registered")
      end
    end
  end
end

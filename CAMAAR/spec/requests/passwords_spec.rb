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
        get_set_password_form(user.email)
        expect_password_form_rendered
      end
    end

    context "when user already has a password" do
      let(:user) { create(:user) }

      it "redirects to login page" do
        get set_password_path(email: user.email)
        expect(response).to redirect_to(login_path)
      end

      it "shows error message" do
        get_set_password_form(user.email)
        expect_password_error("Password already registered")
      end
    end
  end

  describe "POST /set_password" do
    let(:user) { User.create!(email: "newuser@example.com") }

    context "with matching passwords" do
      it "sets the user password" do
        post_set_password(email: user.email, password: "newpassword123", password_confirmation: "newpassword123")
        expect_password_set(user)
      end

      it "allows login with new password" do
        post_set_password(email: user.email, password: "newpassword123", password_confirmation: "newpassword123")
        expect_password_authenticates(user, "newpassword123")
      end

      it "redirects to login page" do
        post_set_password(email: user.email, password: "newpassword123", password_confirmation: "newpassword123")
        expect(response).to redirect_to(login_path)
      end

      it "shows success message" do
        post_set_password(email: user.email, password: "newpassword123", password_confirmation: "newpassword123")
        expect_password_set_success
      end
    end

    context "with mismatched passwords" do
      it "does not set the password" do
        post_set_password(email: user.email, password: "newpassword123", password_confirmation: "differentpassword")
        expect_password_not_set(user)
      end

      it "returns unprocessable entity status" do
        post_set_password(email: user.email, password: "newpassword123", password_confirmation: "differentpassword")
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "shows error message" do
        post_set_password(email: user.email, password: "newpassword123", password_confirmation: "differentpassword")
        expect_password_error("Passwords do not match")
      end
    end

    context "when user not found" do
      it "returns unprocessable entity status" do
        post_set_password(email: "nonexistent@example.com", password: "newpassword123", password_confirmation: "newpassword123")
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "shows error message" do
        post_set_password(email: "nonexistent@example.com", password: "newpassword123", password_confirmation: "newpassword123")
        expect_password_error("User not found")
      end
    end

    context "when user already has a password" do
      let(:existing_user) { create(:user) }

      it "does not change the password" do
        expect_password_unchanged(existing_user) do
          post_set_password(email: existing_user.email, password: "newpassword123", password_confirmation: "newpassword123")
        end
      end

      it "redirects to login page" do
        post_set_password(email: existing_user.email, password: "newpassword123", password_confirmation: "newpassword123")
        expect(response).to redirect_to(login_path)
      end

      it "shows error message" do
        post_set_password(email: existing_user.email, password: "newpassword123", password_confirmation: "newpassword123")
        expect_password_error("Password already registered")
      end
    end
  end
end

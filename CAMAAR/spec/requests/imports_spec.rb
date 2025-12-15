require 'rails_helper'

RSpec.describe "Imports", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  describe "POST /imports" do
    context "when logged in as admin" do
      before do
        post login_path, params: { email: admin_user.email, password: "password123" }
      end

      context "with successful import" do
        before do
          mock_successful_import
        end

        it "calls JsonImportService" do
          expect_any_instance_of(JsonImportService).to receive(:call)
          post imports_path
        end

        it "redirects to gerenciamento page" do
          post imports_path
          expect(response).to redirect_to(gerenciamento_path)
        end

        it "shows success message with statistics" do
          post_import
          expect_import_success
          expect_import_statistics(users: 5, courses: 3, enrollments: 15)
        end

        it "shows skipped statistics" do
          post_import
          expect_import_statistics(users_skipped: 2)
        end
      end

      context "with import errors" do
        before do
          mock_failed_import("Classes file not found")
        end

        it "shows error message" do
          post_import
          expect_import_error("Classes file not found")
        end

        it "redirects to gerenciamento page" do
          post imports_path
          expect(response).to redirect_to(gerenciamento_path)
        end
      end
    end

    context "when logged in as non-admin user" do
      before do
        post login_path, params: { email: regular_user.email, password: "password123" }
      end

      it "denies access" do
        post imports_path
        expect(response).to redirect_to(root_path)
      end

      it "does not call the import service" do
        expect_any_instance_of(JsonImportService).not_to receive(:call)
        post imports_path
      end
    end

    context "when not logged in" do
      it "redirects to login page" do
        post imports_path
        expect(response).to redirect_to(login_path)
      end
    end
  end
end

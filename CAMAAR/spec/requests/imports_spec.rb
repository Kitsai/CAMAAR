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
          allow_any_instance_of(JsonImportService).to receive(:call).and_return({
            success: true,
            data: {
              users_created: 5,
              users_skipped: 2,
              courses_created: 3,
              courses_skipped: 0,
              enrollments_created: 15,
              errors: []
            }
          })
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
          post imports_path
          follow_redirect!
          expect(response.body).to include("Import completed successfully")
          expect(response.body).to include("5 users created")
          expect(response.body).to include("3 courses created")
          expect(response.body).to include("15 enrollments created")
        end

        it "shows skipped statistics" do
          post imports_path
          follow_redirect!
          expect(response.body).to include("2 users skipped")
        end
      end

      context "with import errors" do
        before do
          allow_any_instance_of(JsonImportService).to receive(:call).and_return({
            success: false,
            error: "Classes file not found"
          })
        end

        it "shows error message" do
          post imports_path
          follow_redirect!
          expect(response.body).to include("Import failed")
          expect(response.body).to include("Classes file not found")
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

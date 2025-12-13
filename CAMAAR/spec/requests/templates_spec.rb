require 'rails_helper'

RSpec.describe "Templates", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:admin) { admin_user.admin }
  let(:regular_user) { create(:user) }
  let(:valid_attributes) do
    {
      name: "Test Template",
      question_set_attributes: {
        data: JSON.generate([ { question: "What is your name?", type: "text" } ])
      }
    }
  end
  let(:invalid_attributes) do
    {
      name: "",
      question_set_attributes: { data: JSON.generate([]) }
    }
  end

  before do
    # Log in as admin
    post login_path, params: { email: admin_user.email, password: "password123" }
  end

  describe "GET /templates" do
    it "returns http success" do
      get templates_path
      expect(response).to have_http_status(:success)
    end

    it "displays all templates for the current admin" do
      template1 = Template.create!(name: "Template 1", admin: admin, question_set: QuestionSet.create!(data: [ { question: "Q1" } ]))
      template2 = Template.create!(name: "Template 2", admin: admin, question_set: QuestionSet.create!(data: [ { question: "Q2" } ]))

      get templates_path
      expect(response.body).to include("Template 1")
      expect(response.body).to include("Template 2")
    end
  end

  describe "GET /templates/new" do
    it "returns http success" do
      get new_template_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /templates" do
    context "with valid parameters" do
      it "creates a new template" do
        expect {
          post templates_path, params: { template: valid_attributes }
        }.to change(Template, :count).by(1)
      end

      it "creates a new question_set" do
        expect {
          post templates_path, params: { template: valid_attributes }
        }.to change(QuestionSet, :count).by(1)
      end

      it "redirects to templates index" do
        post templates_path, params: { template: valid_attributes }
        expect(response).to redirect_to(templates_path)
      end

      it "shows success message" do
        post templates_path, params: { template: valid_attributes }
        follow_redirect!
        expect(response.body).to include("Template created successfully")
      end
    end

    context "with invalid parameters (no name)" do
      it "does not create a new template" do
        expect {
          post templates_path, params: { template: { name: "", question_set_attributes: { data: JSON.generate([ { question: "Q" } ]) } } }
        }.not_to change(Template, :count)
      end

      it "returns unprocessable entity status" do
        post templates_path, params: { template: { name: "", question_set_attributes: { data: JSON.generate([ { question: "Q" } ]) } } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "re-renders the new template" do
        post templates_path, params: { template: { name: "", question_set_attributes: { data: JSON.generate([ { question: "Q" } ]) } } }
        expect(response.body).to include("New Template")
      end
    end

    context "with invalid parameters (no questions)" do
      it "does not create a new template" do
        expect {
          post templates_path, params: { template: { name: "Test", question_set_attributes: { data: JSON.generate([]) } } }
        }.not_to change(Template, :count)
      end

      it "returns unprocessable entity status" do
        post templates_path, params: { template: { name: "Test", question_set_attributes: { data: JSON.generate([]) } } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /templates/:id/edit" do
    let(:template) { Template.create!(name: "Test", admin: admin, question_set: QuestionSet.create!(data: [ { question: "Q" } ])) }

    it "returns http success" do
      get edit_template_path(template)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /templates/:id" do
    let(:template) { Template.create!(name: "Original", admin: admin, question_set: QuestionSet.create!(data: [ { question: "Q" } ])) }
    let(:new_attributes) { { name: "Updated Template" } }

    it "updates the template" do
      patch template_path(template), params: { template: new_attributes }
      template.reload
      expect(template.name).to eq("Updated Template")
    end

    it "redirects to templates index" do
      patch template_path(template), params: { template: new_attributes }
      expect(response).to redirect_to(templates_path)
    end
  end

  describe "DELETE /templates/:id" do
    let!(:template) { Template.create!(name: "Test", admin: admin, question_set: QuestionSet.create!(data: [ { question: "Q" } ])) }

    it "destroys the template" do
      expect {
        delete template_path(template)
      }.to change(Template, :count).by(-1)
    end

    it "redirects to templates index" do
      delete template_path(template)
      expect(response).to redirect_to(templates_path)
    end
  end

  describe "admin access control" do
    it "redirects non-admin users" do
      delete logout_path
      post login_path, params: { email: regular_user.email, password: "password123" }

      get templates_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include("Admin privileges required")
    end

    it "allows admin users" do
      get templates_path
      expect(response).to have_http_status(:success)
    end
  end
end

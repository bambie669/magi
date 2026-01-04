require 'rails_helper'

RSpec.describe "Milestones", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:tester) { create(:user, role: :tester) }
  let(:project) { create(:project, user: admin) }
  let(:milestone) { create(:milestone, project: project) }

  describe "GET /projects/:project_id/milestones/new" do
    context "as admin" do
      before { sign_in admin }

      it "returns success" do
        get new_project_milestone_path(project)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tester" do
      before { sign_in tester }

      it "denies access" do
        get new_project_milestone_path(project)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /projects/:project_id/milestones" do
    let(:valid_params) do
      {
        milestone: {
          name: "v1.0 Release",
          due_date: 1.month.from_now.to_date
        }
      }
    end

    context "as admin" do
      before { sign_in admin }

      it "creates a milestone" do
        expect {
          post project_milestones_path(project), params: valid_params
        }.to change(Milestone, :count).by(1)
      end

      it "redirects to project" do
        post project_milestones_path(project), params: valid_params
        expect(response).to redirect_to(project_path(project))
      end
    end

    context "as tester" do
      before { sign_in tester }

      it "denies access" do
        expect {
          post project_milestones_path(project), params: valid_params
        }.not_to change(Milestone, :count)
      end
    end
  end

  describe "GET /milestones/:id/edit" do
    context "as admin" do
      before { sign_in admin }

      it "returns success" do
        get edit_milestone_path(milestone)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /milestones/:id" do
    context "as admin" do
      before { sign_in admin }

      it "updates the milestone" do
        patch milestone_path(milestone), params: { milestone: { name: "Updated Name" } }
        expect(milestone.reload.name).to eq("Updated Name")
      end
    end
  end

  describe "DELETE /milestones/:id" do
    context "as admin" do
      before { sign_in admin }

      it "deletes the milestone" do
        milestone # create it first
        expect {
          delete milestone_path(milestone)
        }.to change(Milestone, :count).by(-1)
      end
    end

    context "as tester" do
      before { sign_in tester }

      it "denies access" do
        milestone # create it first
        expect {
          delete milestone_path(milestone)
        }.not_to change(Milestone, :count)
      end
    end
  end
end

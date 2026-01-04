require 'rails_helper'

RSpec.describe "Projects", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:manager) { create(:user, role: :manager) }
  let(:tester) { create(:user, role: :tester) }
  let(:project) { create(:project, user: admin) }
  let(:manager_project) { create(:project, user: manager) }

  describe "GET /projects" do
    context "when user is logged in" do
      before { sign_in admin }

      it "returns http success" do
        get projects_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not logged in" do
      it "redirects to login page" do
        get projects_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /projects/:id" do
    before { sign_in admin }

    it "returns http success" do
      get project_path(project)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /projects/new" do
    before { sign_in admin }

    it "returns http success" do
      get new_project_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /projects" do
    before { sign_in admin }

    it "creates a project and redirects" do
      expect {
        post projects_path, params: { project: { name: "New Project", description: "Test" } }
      }.to change(Project, :count).by(1)
      expect(response).to redirect_to(project_path(Project.last))
    end
  end

  describe "GET /projects/:id/edit" do
    before { sign_in admin }

    it "returns http success" do
      get edit_project_path(project)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /projects/:id" do
    before { sign_in admin }

    it "updates the project and redirects" do
      patch project_path(project), params: { project: { name: "Updated Name" } }
      expect(response).to redirect_to(project_path(project))
      expect(project.reload.name).to eq("Updated Name")
    end
  end

  describe "DELETE /projects/:id" do
    before { sign_in admin }

    it "destroys the project and redirects" do
      project # create it first
      expect {
        delete project_path(project)
      }.to change(Project, :count).by(-1)
      expect(response).to redirect_to(projects_path)
    end
  end

  # Multi-role access tests
  describe "role-based access" do
    describe "viewing projects" do
      %i[admin manager tester].each do |role|
        context "as #{role}" do
          let(:user) { create(:user, role: role) }
          before { sign_in user }

          it "can view projects index" do
            get projects_path
            expect(response).to have_http_status(:success)
          end

          it "can view a project" do
            get project_path(project)
            expect(response).to have_http_status(:success)
          end
        end
      end
    end

    describe "creating projects" do
      context "as admin" do
        before { sign_in admin }

        it "can create projects" do
          expect {
            post projects_path, params: { project: { name: "Admin Project" } }
          }.to change(Project, :count).by(1)
        end
      end

      context "as manager" do
        before { sign_in manager }

        it "can create projects" do
          expect {
            post projects_path, params: { project: { name: "Manager Project" } }
          }.to change(Project, :count).by(1)
        end
      end

      context "as tester" do
        before { sign_in tester }

        it "cannot create projects" do
          expect {
            post projects_path, params: { project: { name: "Tester Project" } }
          }.not_to change(Project, :count)
          expect(response).to redirect_to(root_path)
        end

        it "cannot access new project form" do
          get new_project_path
          expect(response).to redirect_to(root_path)
        end
      end
    end

    describe "editing projects" do
      context "as admin" do
        before { sign_in admin }

        it "can edit own project" do
          get edit_project_path(project)
          expect(response).to have_http_status(:success)
        end

        it "can edit any project" do
          get edit_project_path(manager_project)
          expect(response).to have_http_status(:success)
        end
      end

      context "as manager" do
        before { sign_in manager }

        it "can edit own project" do
          get edit_project_path(manager_project)
          expect(response).to have_http_status(:success)
        end
      end

      context "as tester" do
        before { sign_in tester }

        it "cannot edit projects" do
          get edit_project_path(project)
          expect(response).to redirect_to(root_path)
        end
      end
    end

    describe "deleting projects" do
      context "as admin" do
        before { sign_in admin }

        it "can delete projects" do
          project # create
          expect {
            delete project_path(project)
          }.to change(Project, :count).by(-1)
        end
      end

      context "as manager" do
        before { sign_in manager }

        it "cannot delete projects (admin only)" do
          manager_project # create
          expect {
            delete project_path(manager_project)
          }.not_to change(Project, :count)
          expect(response).to redirect_to(root_path)
        end
      end

      context "as tester" do
        before { sign_in tester }

        it "cannot delete projects" do
          project # create
          expect {
            delete project_path(project)
          }.not_to change(Project, :count)
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end

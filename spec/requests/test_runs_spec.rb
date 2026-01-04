require 'rails_helper'

RSpec.describe "TestRuns", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:manager) { create(:user, role: :manager) }
  let(:tester) { create(:user, role: :tester) }
  let(:project) { create(:project, user: admin) }
  let(:test_suite) { create(:test_suite, project: project) }
  let(:test_scope) { create(:test_scope, test_suite: test_suite) }
  let!(:test_case) { create(:test_case, test_scope: test_scope) }
  let(:test_run) { create(:test_run, project: project, user: admin) }
  let(:tester_test_run) { create(:test_run, project: project, user: tester) }

  describe "GET /test_runs" do
    before { sign_in admin }

    it "returns http success" do
      get test_runs_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /projects/:project_id/test_runs" do
    before { sign_in admin }

    it "returns http success" do
      get project_test_runs_path(project)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /test_runs/:id" do
    before { sign_in admin }

    it "returns http success" do
      get test_run_path(test_run)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /projects/:project_id/test_runs/new" do
    before { sign_in admin }

    it "returns http success" do
      get new_project_test_run_path(project)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /projects/:project_id/test_runs" do
    before { sign_in admin }

    it "creates a test run with selected test cases" do
      expect {
        post project_test_runs_path(project), params: {
          test_run: { name: "New Test Run", test_case_ids: [test_case.id] }
        }
      }.to change(TestRun, :count).by(1)
      expect(response).to redirect_to(test_run_path(TestRun.last))
    end
  end

  describe "GET /test_runs/:id/edit" do
    before { sign_in admin }

    it "returns http success" do
      get edit_test_run_path(test_run)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /test_runs/:id" do
    before { sign_in admin }

    it "updates the test run" do
      patch test_run_path(test_run), params: { test_run: { name: "Updated Run" } }
      expect(response).to redirect_to(test_run_path(test_run))
      expect(test_run.reload.name).to eq("Updated Run")
    end
  end

  describe "DELETE /test_runs/:id" do
    before { sign_in admin }

    it "destroys the test run" do
      test_run # create it
      expect {
        delete test_run_path(test_run)
      }.to change(TestRun, :count).by(-1)
      expect(response).to redirect_to(project_test_runs_path(project))
    end
  end

  # Multi-role access tests
  describe "role-based access" do
    describe "viewing test runs" do
      %i[admin manager tester].each do |role|
        context "as #{role}" do
          let(:user) { create(:user, role: role) }
          before { sign_in user }

          it "can view test runs index" do
            get test_runs_path
            expect(response).to have_http_status(:success)
          end

          it "can view project test runs" do
            get project_test_runs_path(project)
            expect(response).to have_http_status(:success)
          end

          it "can view a test run" do
            get test_run_path(test_run)
            expect(response).to have_http_status(:success)
          end
        end
      end
    end

    describe "creating test runs" do
      %i[admin manager tester].each do |role|
        context "as #{role}" do
          let(:user) { create(:user, role: role) }
          before { sign_in user }

          it "can create test runs" do
            expect {
              post project_test_runs_path(project), params: {
                test_run: { name: "#{role.to_s.titleize} Test Run", test_case_ids: [test_case.id] }
              }
            }.to change(TestRun, :count).by(1)
          end

          it "associates test run with current user" do
            post project_test_runs_path(project), params: {
              test_run: { name: "My Run", test_case_ids: [test_case.id] }
            }
            expect(TestRun.last.user).to eq(user)
          end
        end
      end
    end

    describe "editing test runs" do
      context "as admin" do
        before { sign_in admin }

        it "can edit any test run" do
          get edit_test_run_path(tester_test_run)
          expect(response).to have_http_status(:success)
        end

        it "can update any test run" do
          patch test_run_path(tester_test_run), params: { test_run: { name: "Admin Updated" } }
          expect(tester_test_run.reload.name).to eq("Admin Updated")
        end
      end

      context "as tester" do
        before { sign_in tester }

        it "cannot edit test runs (admin/manager only)" do
          get edit_test_run_path(tester_test_run)
          expect(response).to redirect_to(root_path)
        end
      end

      context "as manager" do
        before { sign_in manager }
        let(:manager_test_run) { create(:test_run, project: project, user: manager) }

        it "can edit own test run" do
          get edit_test_run_path(manager_test_run)
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe "deleting test runs" do
      context "as admin" do
        before { sign_in admin }

        it "can delete any test run" do
          tester_test_run # create
          expect {
            delete test_run_path(tester_test_run)
          }.to change(TestRun, :count).by(-1)
        end
      end

      context "as tester" do
        before { sign_in tester }

        it "cannot delete test runs" do
          tester_test_run # create
          expect {
            delete test_run_path(tester_test_run)
          }.not_to change(TestRun, :count)
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end

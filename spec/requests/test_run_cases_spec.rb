require 'rails_helper'

RSpec.describe "TestRunCases", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:project) { create(:project, user: admin) }
  let(:test_suite) { create(:test_suite, project: project) }
  let(:test_scope) { create(:test_scope, test_suite: test_suite) }
  let(:test_case) { create(:test_case, test_scope: test_scope) }
  let(:test_run) { create(:test_run, project: project, user: admin) }
  let!(:test_run_case) { create(:test_run_case, test_run: test_run, test_case: test_case) }

  describe "PATCH /test_run_cases/:id" do
    before { sign_in admin }

    it "updates the test run case status" do
      patch test_run_case_path(test_run_case), params: {
        test_run_case: { status: "passed", comments: "Test passed successfully" }
      }
      expect(response).to redirect_to(test_run_path(test_run))
      expect(test_run_case.reload.status).to eq("passed")
      expect(test_run_case.comments).to eq("Test passed successfully")
    end

    it "can mark as failed" do
      patch test_run_case_path(test_run_case), params: {
        test_run_case: { status: "failed", comments: "Bug found" }
      }
      expect(test_run_case.reload.status).to eq("failed")
    end

    it "can mark as blocked" do
      patch test_run_case_path(test_run_case), params: {
        test_run_case: { status: "blocked", comments: "Blocked by dependency" }
      }
      expect(test_run_case.reload.status).to eq("blocked")
    end
  end

  describe "when user is not logged in" do
    it "redirects to login page" do
      patch test_run_case_path(test_run_case), params: {
        test_run_case: { status: "passed" }
      }
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end

require 'rails_helper'

RSpec.describe "TestRunCases", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:tester) { create(:user, role: :tester) }
  let(:project) { create(:project, user: admin) }
  let(:test_suite) { create(:test_suite, project: project) }
  let(:test_scope) { create(:test_scope, test_suite: test_suite) }
  let(:test_case) { create(:test_case, test_scope: test_scope) }
  let(:test_run) { create(:test_run, project: project, user: admin) }
  let!(:test_run_case) { create(:test_run_case, test_run: test_run, test_case: test_case) }

  describe "PATCH /test_run_cases/:id (HTML)" do
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

    it "can reset to untested" do
      test_run_case.update!(status: :passed)
      patch test_run_case_path(test_run_case), params: {
        test_run_case: { status: "untested" }
      }
      expect(test_run_case.reload.status).to eq("untested")
    end

    it "updates status when changing from untested" do
      expect(test_run_case.status).to eq("untested")
      patch test_run_case_path(test_run_case), params: {
        test_run_case: { status: "passed" }
      }
      expect(test_run_case.reload.status).to eq("passed")
    end
  end

  describe "PATCH /test_run_cases/:id (JSON)" do
    before { sign_in admin }

    it "returns success JSON response" do
      patch test_run_case_path(test_run_case),
        params: { test_run_case: { status: "passed" } },
        headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' },
        as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['status']).to eq('success')
    end

    it "returns updated status in JSON" do
      patch test_run_case_path(test_run_case),
        params: { test_run_case: { status: "failed" } },
        headers: { 'Accept' => 'application/json' },
        as: :json

      json = JSON.parse(response.body)
      expect(json['test_run_case']['status']).to eq('failed')
    end
  end

  describe "role-based access" do
    context "as tester" do
      before { sign_in tester }

      it "can update test run case status" do
        patch test_run_case_path(test_run_case), params: {
          test_run_case: { status: "passed" }
        }
        expect(test_run_case.reload.status).to eq("passed")
      end
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

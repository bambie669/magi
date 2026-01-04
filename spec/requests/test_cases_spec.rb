require 'rails_helper'

RSpec.describe "TestCases", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:tester) { create(:user, role: :tester) }
  let(:project) { create(:project, user: admin) }
  let(:test_suite) { create(:test_suite, project: project) }
  let(:test_scope) { create(:test_scope, test_suite: test_suite) }
  let(:test_case) { create(:test_case, test_scope: test_scope) }

  describe "GET /test_suites/:test_suite_id/test_cases/new" do
    context "when authenticated" do
      before { sign_in admin }

      it "returns success" do
        get new_test_suite_test_case_path(test_suite)
        expect(response).to have_http_status(:success)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get new_test_suite_test_case_path(test_suite)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /test_suites/:test_suite_id/test_cases" do
    context "when authenticated" do
      before { sign_in admin }

      let(:valid_params) do
        {
          test_case: {
            title: "Login Flow Test",
            preconditions: "User exists",
            steps: "1. Go to login\n2. Enter credentials",
            expected_result: "User is logged in",
            test_scope_id: test_scope.id
          }
        }
      end

      it "creates a test case" do
        expect {
          post test_suite_test_cases_path(test_suite), params: valid_params
        }.to change(TestCase, :count).by(1)
      end

      it "redirects to test suite" do
        post test_suite_test_cases_path(test_suite), params: valid_params
        expect(response).to redirect_to(test_suite_path(test_suite))
      end
    end
  end

  describe "GET /test_cases/:id" do
    context "when authenticated" do
      before { sign_in admin }

      it "returns success" do
        get test_case_path(test_case)
        expect(response).to have_http_status(:success)
      end

      it "displays test case content" do
        get test_case_path(test_case)
        # Check for expected result which should be displayed on the page
        expect(response.body).to include(test_case.expected_result)
      end
    end
  end

  describe "GET /test_cases/:id/edit" do
    context "when authenticated" do
      before { sign_in admin }

      it "returns success" do
        get edit_test_case_path(test_case)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /test_cases/:id" do
    context "when authenticated" do
      before { sign_in admin }

      it "updates the test case" do
        patch test_case_path(test_case), params: { test_case: { title: "Updated Title" } }
        expect(test_case.reload.title).to eq("Updated Title")
      end

      it "redirects to test case" do
        patch test_case_path(test_case), params: { test_case: { title: "Updated" } }
        expect(response).to redirect_to(test_case_path(test_case))
      end
    end
  end

  describe "DELETE /test_cases/:id" do
    context "as admin" do
      before { sign_in admin }

      it "deletes the test case" do
        test_case # create it first
        expect {
          delete test_case_path(test_case)
        }.to change(TestCase, :count).by(-1)
      end

      it "redirects to test suite" do
        ts = test_case.test_suite
        delete test_case_path(test_case)
        expect(response).to redirect_to(test_suite_path(ts))
      end
    end

    context "as tester" do
      before { sign_in tester }

      it "denies access" do
        test_case # create it first
        expect {
          delete test_case_path(test_case)
        }.not_to change(TestCase, :count)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "TestSuites", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:manager) { create(:user, :manager) }
  let(:tester) { create(:user) }
  let(:project) { create(:project, user: admin) }
  let(:test_suite) { create(:test_suite, project: project) }

  describe "DELETE /test_suites/:id" do
    context "when user is admin" do
      before { sign_in admin }

      it "destroys the test suite" do
        test_suite # create the test suite
        expect {
          delete test_suite_path(test_suite)
        }.to change(TestSuite, :count).by(-1)
      end

      it "redirects to the project page" do
        delete test_suite_path(test_suite)
        expect(response).to redirect_to(project_path(project))
      end

      it "shows a success notice" do
        delete test_suite_path(test_suite)
        follow_redirect!
        expect(response.body).to include("successfully destroyed")
      end

      it "cascades delete to test scopes" do
        test_scope = create(:test_scope, test_suite: test_suite)
        expect {
          delete test_suite_path(test_suite)
        }.to change(TestScope, :count).by(-1)
      end

      it "cascades delete to test cases" do
        test_scope = create(:test_scope, test_suite: test_suite)
        create(:test_case, test_scope: test_scope)
        create(:test_case, test_scope: test_scope)
        expect {
          delete test_suite_path(test_suite)
        }.to change(TestCase, :count).by(-2)
      end
    end

    context "when user is manager" do
      before { sign_in manager }

      it "destroys the test suite" do
        test_suite
        expect {
          delete test_suite_path(test_suite)
        }.to change(TestSuite, :count).by(-1)
      end

      it "redirects to the project page" do
        delete test_suite_path(test_suite)
        expect(response).to redirect_to(project_path(project))
      end
    end

    context "when user is tester" do
      before { sign_in tester }

      it "does not destroy the test suite" do
        test_suite
        expect {
          delete test_suite_path(test_suite)
        }.not_to change(TestSuite, :count)
      end

      it "returns forbidden status" do
        delete test_suite_path(test_suite)
        # Pundit raises NotAuthorizedError which could redirect or return 403
        expect(response).to have_http_status(:forbidden).or redirect_to(root_path)
      end
    end

    context "when user is not logged in" do
      it "redirects to login page" do
        delete test_suite_path(test_suite)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not destroy the test suite" do
        test_suite
        expect {
          delete test_suite_path(test_suite)
        }.not_to change(TestSuite, :count)
      end
    end

    context "when test suite does not exist" do
      before { sign_in admin }

      it "redirects to root with alert" do
        delete test_suite_path(id: 999999)
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("not found")
      end
    end
  end

  describe "GET /test_suites/:id (show page)" do
    before { sign_in admin }

    it "displays delete button for admin" do
      get test_suite_path(test_suite)
      expect(response.body).to include("Purge Bank")
    end
  end
end

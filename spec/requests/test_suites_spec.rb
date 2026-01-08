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
      expect(response.body).to include("Delete Suite")
    end
  end

  describe "GET /test_suites/:id/export_csv" do
    before { sign_in admin }

    let(:test_scope) { create(:test_scope, test_suite: test_suite) }

    before do
      create(:test_case, test_scope: test_scope, title: "Test 1", cypress_id: "TC-001")
      create(:test_case, test_scope: test_scope, title: "Test 2", cypress_id: "TC-002")
    end

    it "returns CSV file" do
      get export_csv_test_suite_path(test_suite)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("text/csv")
    end

    it "includes test cases in CSV" do
      get export_csv_test_suite_path(test_suite)
      expect(response.body).to include("Test 1")
      expect(response.body).to include("Test 2")
    end

    it "includes cypress_id in CSV" do
      get export_csv_test_suite_path(test_suite)
      expect(response.body).to include("TC-001")
    end
  end

  describe "GET /test_suites/:id/csv_template" do
    before { sign_in admin }

    it "returns CSV template" do
      get csv_template_test_suite_path(test_suite)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("text/csv")
    end

    it "includes headers only" do
      get csv_template_test_suite_path(test_suite)
      expect(response.body).to include("scope_path")
      expect(response.body).to include("title")
      lines = response.body.strip.split("\n")
      expect(lines.length).to eq(1)
    end
  end

  describe "GET /test_suites/:id/import_csv" do
    before { sign_in admin }

    it "renders import form" do
      get import_csv_test_suite_path(test_suite)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Import")
    end
  end

  describe "POST /test_suites/:id/process_import_csv" do
    before { sign_in admin }

    let(:csv_content) do
      <<~CSV
        scope_path,title,steps,expected_result,cypress_id
        Login,Test Case 1,Step 1,Result 1,TC-001
        Login,Test Case 2,Step 2,Result 2,TC-002
      CSV
    end

    let(:csv_file) do
      file = Tempfile.new(['test', '.csv'])
      file.write(csv_content)
      file.rewind
      Rack::Test::UploadedFile.new(file.path, 'text/csv')
    end

    it "imports test cases from CSV" do
      expect {
        post process_import_csv_test_suite_path(test_suite), params: { csv_files: [csv_file] }
      }.to change(TestCase, :count).by(2)
    end

    it "redirects to test suite on success" do
      post process_import_csv_test_suite_path(test_suite), params: { csv_files: [csv_file] }
      expect(response).to redirect_to(test_suite_path(test_suite))
    end

    it "shows success message" do
      post process_import_csv_test_suite_path(test_suite), params: { csv_files: [csv_file] }
      follow_redirect!
      expect(response.body).to include("imported")
    end

    context "without file" do
      it "shows error" do
        post process_import_csv_test_suite_path(test_suite)
        expect(response).to redirect_to(import_csv_test_suite_path(test_suite))
      end
    end
  end

  describe "DELETE /test_suites/:id/bulk_destroy_cases" do
    before { sign_in admin }

    let(:test_scope) { create(:test_scope, test_suite: test_suite) }
    let!(:test_case1) { create(:test_case, test_scope: test_scope) }
    let!(:test_case2) { create(:test_case, test_scope: test_scope) }

    it "destroys selected test cases" do
      expect {
        delete bulk_destroy_cases_test_suite_path(test_suite), params: { ids: [test_case1.id, test_case2.id] }
      }.to change(TestCase, :count).by(-2)
    end

    it "returns JSON response" do
      delete bulk_destroy_cases_test_suite_path(test_suite),
        params: { ids: [test_case1.id] },
        as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['destroyed']).to eq(1)
    end
  end
end

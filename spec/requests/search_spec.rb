require 'rails_helper'

RSpec.describe "Search", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "GET /search" do
    context "when not authenticated" do
      it "redirects to sign in" do
        get search_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      context "without a query" do
        it "returns successful response" do
          get search_path
          expect(response).to have_http_status(:success)
        end

        it "shows empty state" do
          get search_path
          expect(response.body).to include("MAGI Database Scanner Ready")
        end
      end

      context "with a query" do
        let!(:project) { create(:project, name: "Alpha Project", description: "Test description", user: user) }
        let!(:other_project) { create(:project, name: "Beta Project", user: other_user) }
        let!(:test_suite) { create(:test_suite, name: "Alpha Suite", project: project) }
        let!(:test_scope) { create(:test_scope, test_suite: test_suite) }
        let!(:test_case) { create(:test_case, title: "Alpha Test Case", test_scope: test_scope) }
        let!(:test_run) { create(:test_run, name: "Alpha Run", project: project) }

        it "finds matching projects" do
          get search_path, params: { q: "Alpha" }
          expect(response).to have_http_status(:success)
          expect(response.body).to include("Alpha Project")
        end

        it "finds matching test suites" do
          get search_path, params: { q: "Alpha" }
          expect(response.body).to include("Alpha Suite")
        end

        it "finds matching test cases" do
          get search_path, params: { q: "Alpha" }
          expect(response.body).to include("Alpha Test Case")
        end

        it "finds matching test runs" do
          get search_path, params: { q: "Alpha" }
          expect(response.body).to include("Alpha Run")
        end

        it "shows total results count" do
          get search_path, params: { q: "Alpha" }
          expect(response.body).to include("Results found")
        end

        it "is case insensitive" do
          get search_path, params: { q: "alpha" }
          expect(response.body).to include("Alpha Project")
        end

        it "searches project descriptions" do
          get search_path, params: { q: "description" }
          expect(response.body).to include("Alpha Project")
        end

        context "when no results found" do
          it "shows no results message" do
            get search_path, params: { q: "nonexistent" }
            expect(response.body).to include("No results found")
          end
        end

        context "with whitespace query" do
          it "handles empty trimmed query" do
            get search_path, params: { q: "   " }
            expect(response.body).to include("MAGI Database Scanner Ready")
          end
        end
      end

      context "policy scoping" do
        let!(:admin) { create(:user, :admin) }
        let!(:user_project) { create(:project, name: "User Project", user: user) }
        let!(:other_project) { create(:project, name: "Other Project", user: other_user) }

        # Note: Per ProjectPolicy, testers can see all projects
        it "tester can see all projects" do
          get search_path, params: { q: "Project" }
          expect(response.body).to include("User Project")
          expect(response.body).to include("Other Project")
        end

        it "admin sees all projects" do
          sign_in admin
          get search_path, params: { q: "Project" }
          expect(response.body).to include("User Project")
          expect(response.body).to include("Other Project")
        end
      end
    end
  end
end

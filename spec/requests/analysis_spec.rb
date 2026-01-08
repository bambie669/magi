require 'rails_helper'

RSpec.describe "Analysis", type: :request do
  let(:user) { create(:user) }

  describe "GET /analysis" do
    context "when not authenticated" do
      it "redirects to sign in" do
        get analysis_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "returns successful response" do
        get analysis_path
        expect(response).to have_http_status(:success)
      end

      it "displays page title" do
        get analysis_path
        expect(response.body).to include("Analysis")
      end

      it "displays Analysis Dashboard" do
        get analysis_path
        expect(response.body).to include("Analysis Dashboard")
      end

      context "with no data" do
        it "shows zero counts" do
          get analysis_path
          expect(response.body).to include("0")
        end

        it "shows Quality Summary" do
          get analysis_path
          expect(response.body).to include("Quality Summary")
        end
      end

      context "with test data" do
        let!(:project) { create(:project, user: user) }
        let!(:test_suite) { create(:test_suite, project: project) }
        let!(:test_scope) { create(:test_scope, test_suite: test_suite) }
        let!(:test_case) { create(:test_case, test_scope: test_scope) }
        let!(:test_run) { create(:test_run, project: project) }
        let!(:test_run_case) { create(:test_run_case, test_run: test_run, test_case: test_case, status: 'passed') }

        it "displays project count" do
          get analysis_path
          expect(response.body).to include("Projects")
          expect(response.body).to include("1")
        end

        it "displays test suite count" do
          get analysis_path
          expect(response.body).to include("Test Suites")
        end

        it "displays test case count" do
          get analysis_path
          expect(response.body).to include("Test Cases")
        end

        it "displays test run count" do
          get analysis_path
          expect(response.body).to include("Test Runs")
        end

        it "displays test results summary" do
          get analysis_path
          expect(response.body).to include("Test Results Summary")
        end

        it "displays status counts" do
          get analysis_path
          expect(response.body).to include("Passed")
          expect(response.body).to include("Failed")
          expect(response.body).to include("Blocked")
          expect(response.body).to include("Not Run")
        end

        it "displays pass rate" do
          get analysis_path
          expect(response.body).to include("Overall Pass Rate")
        end

        it "displays test runs by project" do
          get analysis_path
          expect(response.body).to include("Test Runs by Project")
        end

        it "displays test executions chart" do
          get analysis_path
          expect(response.body).to include("Test Executions")
        end

        it "displays top projects" do
          get analysis_path
          expect(response.body).to include("Top Projects by Test Cases")
        end

        it "displays recent test runs" do
          get analysis_path
          expect(response.body).to include("Recent Test Runs")
        end
      end

      context "with different pass rates" do
        let!(:project) { create(:project, user: user) }
        let!(:test_suite) { create(:test_suite, project: project) }
        let!(:test_scope) { create(:test_scope, test_suite: test_suite) }
        let!(:test_run) { create(:test_run, project: project) }

        context "with high pass rate (>= 80%)" do
          before do
            8.times do
              tc = create(:test_case, test_scope: test_scope)
              create(:test_run_case, test_run: test_run, test_case: tc, status: 'passed')
            end
            2.times do
              tc = create(:test_case, test_scope: test_scope)
              create(:test_run_case, test_run: test_run, test_case: tc, status: 'failed')
            end
          end

          it "shows Healthy status" do
            get analysis_path
            expect(response.body).to include("Healthy")
          end
        end

        context "with medium pass rate (50-69%)" do
          before do
            6.times do
              tc = create(:test_case, test_scope: test_scope)
              create(:test_run_case, test_run: test_run, test_case: tc, status: 'passed')
            end
            4.times do
              tc = create(:test_case, test_scope: test_scope)
              create(:test_run_case, test_run: test_run, test_case: tc, status: 'failed')
            end
          end

          it "shows Needs Improvement status" do
            get analysis_path
            expect(response.body).to include("Needs Improvement")
          end
        end

        context "with low pass rate (< 50%)" do
          before do
            3.times do
              tc = create(:test_case, test_scope: test_scope)
              create(:test_run_case, test_run: test_run, test_case: tc, status: 'passed')
            end
            7.times do
              tc = create(:test_case, test_scope: test_scope)
              create(:test_run_case, test_run: test_run, test_case: tc, status: 'failed')
            end
          end

          it "shows Critical status" do
            get analysis_path
            expect(response.body).to include("Critical")
          end
        end
      end

      context "policy scoping" do
        let!(:admin) { create(:user, :admin) }
        let!(:user_project) { create(:project, user: user) }
        let!(:other_user) { create(:user) }
        let!(:other_project) { create(:project, user: other_user) }

        # Note: Per ProjectPolicy, testers can see all projects
        it "tester sees all project stats" do
          get analysis_path
          # Tester should see 2 projects (all of them per policy)
          expect(response.body).to match(/Projects.*?2/m)
        end

        it "admin sees all project stats" do
          sign_in admin
          get analysis_path
          # Admin should see 2 projects
          expect(response.body).to match(/Projects.*?2/m)
        end
      end
    end
  end
end

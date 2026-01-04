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
        expect(response.body).to include("SYSTEM ANALYSIS")
      end

      it "displays MAGI Analysis Module" do
        get analysis_path
        expect(response.body).to include("MAGI Analysis Module")
      end

      context "with no data" do
        it "shows zero counts" do
          get analysis_path
          expect(response.body).to include("0")
        end

        it "shows MAGI consensus" do
          get analysis_path
          expect(response.body).to include("CASPER")
          expect(response.body).to include("BALTHASAR")
          expect(response.body).to include("MELCHIOR")
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
          expect(response.body).to include("MISSIONS")
          expect(response.body).to include("1")
        end

        it "displays test suite count" do
          get analysis_path
          expect(response.body).to include("PROTOCOL BANKS")
        end

        it "displays test case count" do
          get analysis_path
          expect(response.body).to include("PROTOCOLS")
        end

        it "displays test run count" do
          get analysis_path
          expect(response.body).to include("OPERATIONS")
        end

        it "displays system integrity report" do
          get analysis_path
          expect(response.body).to include("SYSTEM INTEGRITY REPORT")
        end

        it "displays status counts" do
          get analysis_path
          expect(response.body).to include("NOMINAL")
          expect(response.body).to include("BREACH")
          expect(response.body).to include("PATTERN BLUE")
          expect(response.body).to include("STANDBY")
        end

        it "displays pass rate" do
          get analysis_path
          expect(response.body).to include("Overall Pass Rate")
        end

        it "displays operations by mission" do
          get analysis_path
          expect(response.body).to include("OPERATIONS BY MISSION")
        end

        it "displays execution telemetry" do
          get analysis_path
          expect(response.body).to include("EXECUTION TELEMETRY")
        end

        it "displays top missions" do
          get analysis_path
          expect(response.body).to include("TOP MISSIONS BY PROTOCOLS")
        end

        it "displays recent operations" do
          get analysis_path
          expect(response.body).to include("RECENT OPERATIONS")
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

          it "shows SYSTEM NOMINAL verdict" do
            get analysis_path
            expect(response.body).to include("SYSTEM NOMINAL")
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

          it "shows CAUTION ADVISED verdict" do
            get analysis_path
            expect(response.body).to include("CAUTION ADVISED")
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

          it "shows CRITICAL REVIEW REQUIRED verdict" do
            get analysis_path
            expect(response.body).to include("CRITICAL REVIEW REQUIRED")
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
          expect(response.body).to match(/MISSIONS.*?2/m)
        end

        it "admin sees all project stats" do
          sign_in admin
          get analysis_path
          # Admin should see 2 projects
          expect(response.body).to match(/MISSIONS.*?2/m)
        end
      end
    end
  end
end

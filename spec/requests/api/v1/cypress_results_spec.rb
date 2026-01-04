require 'rails_helper'

RSpec.describe "Api::V1::CypressResults", type: :request do
  let(:user) { create(:user, :admin) }
  let(:api_token) { create(:api_token, user: user) }
  let(:project) { create(:project, user: user) }
  let(:test_suite) { create(:test_suite, project: project) }
  let(:test_scope) { create(:test_scope, test_suite: test_suite) }
  let(:test_run) { create(:test_run, project: project, user: user) }

  let(:headers) do
    {
      "Authorization" => "Bearer #{api_token.token}",
      "Content-Type" => "application/json"
    }
  end

  describe "POST /api/v1/test_runs/:test_run_id/cypress_results" do
    let(:endpoint) { "/api/v1/test_runs/#{test_run.id}/cypress_results" }

    context "with valid authentication" do
      context "when test cases exist" do
        let!(:test_case1) { create(:test_case, test_scope: test_scope, cypress_id: "TC-001") }
        let!(:test_case2) { create(:test_case, test_scope: test_scope, cypress_id: "TC-002") }
        let!(:test_run_case1) { create(:test_run_case, test_run: test_run, test_case: test_case1) }
        let!(:test_run_case2) { create(:test_run_case, test_run: test_run, test_case: test_case2) }

        it "updates test run cases with passed status" do
          results = [
            { cypress_id: "TC-001", status: "passed", duration_ms: 1234 },
            { cypress_id: "TC-002", status: "passed", duration_ms: 5678 }
          ]

          post endpoint, params: { results: results }.to_json, headers: headers

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)

          expect(json["message"]).to eq("Results processed successfully")
          expect(json["summary"]["updated"]).to eq(2)
          expect(json["summary"]["not_found"]).to eq(0)

          expect(test_run_case1.reload.status).to eq("passed")
          expect(test_run_case2.reload.status).to eq("passed")
        end

        it "updates test run cases with failed status and error message" do
          results = [
            {
              cypress_id: "TC-001",
              status: "failed",
              duration_ms: 1234,
              error_message: "AssertionError: expected true to be false"
            }
          ]

          post endpoint, params: { results: results }.to_json, headers: headers

          expect(response).to have_http_status(:ok)

          test_run_case1.reload
          expect(test_run_case1.status).to eq("failed")
          expect(test_run_case1.comments).to include("[Cypress] Error:")
          expect(test_run_case1.comments).to include("AssertionError")
        end

        it "maps skipped status to blocked" do
          results = [{ cypress_id: "TC-001", status: "skipped", duration_ms: 0 }]

          post endpoint, params: { results: results }.to_json, headers: headers

          expect(test_run_case1.reload.status).to eq("blocked")
        end

        it "maps pending status to blocked" do
          results = [{ cypress_id: "TC-001", status: "pending", duration_ms: 0 }]

          post endpoint, params: { results: results }.to_json, headers: headers

          expect(test_run_case1.reload.status).to eq("blocked")
        end

        it "appends duration to comments" do
          results = [{ cypress_id: "TC-001", status: "passed", duration_ms: 1500 }]

          post endpoint, params: { results: results }.to_json, headers: headers

          expect(test_run_case1.reload.comments).to include("[Cypress] Duration: 1500ms")
        end

        it "appends to existing comments" do
          test_run_case1.update!(comments: "Previous comment")

          results = [{ cypress_id: "TC-001", status: "passed", duration_ms: 1000 }]

          post endpoint, params: { results: results }.to_json, headers: headers

          comments = test_run_case1.reload.comments
          expect(comments).to include("Previous comment")
          expect(comments).to include("---")
          expect(comments).to include("[Cypress] Duration: 1000ms")
        end

        it "updates last_used_at on api token" do
          expect(api_token.last_used_at).to be_nil

          results = [{ cypress_id: "TC-001", status: "passed", duration_ms: 1000 }]

          freeze_time do
            post endpoint, params: { results: results }.to_json, headers: headers
            expect(api_token.reload.last_used_at).to eq(Time.current)
          end
        end
      end

      context "when test case not found" do
        it "reports not_found in summary" do
          results = [{ cypress_id: "NONEXISTENT", status: "passed", duration_ms: 1000 }]

          post endpoint, params: { results: results }.to_json, headers: headers

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)

          expect(json["summary"]["not_found"]).to eq(1)
          expect(json["summary"]["updated"]).to eq(0)
          expect(json["summary"]["errors"]).to include("TestCase with cypress_id 'NONEXISTENT' not found")
        end
      end

      context "when test case exists but not in test run" do
        let!(:other_test_case) { create(:test_case, test_scope: test_scope, cypress_id: "TC-999") }

        it "reports not_found in summary" do
          results = [{ cypress_id: "TC-999", status: "passed", duration_ms: 1000 }]

          post endpoint, params: { results: results }.to_json, headers: headers

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)

          expect(json["summary"]["not_found"]).to eq(1)
          expect(json["summary"]["errors"]).to include("TestCase 'TC-999' is not part of this test run")
        end
      end

      context "with empty results" do
        it "returns success with zero counts" do
          post endpoint, params: { results: [] }.to_json, headers: headers

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)

          expect(json["summary"]["total"]).to eq(0)
          expect(json["summary"]["updated"]).to eq(0)
        end
      end
    end

    context "with invalid authentication" do
      it "returns unauthorized without token" do
        post endpoint, params: { results: [] }.to_json, headers: { "Content-Type" => "application/json" }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to include("Unauthorized")
      end

      it "returns unauthorized with invalid token" do
        headers["Authorization"] = "Bearer invalid_token"

        post endpoint, params: { results: [] }.to_json, headers: headers

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns unauthorized with expired token" do
        expired_token = create(:api_token, :expired, user: user)
        headers["Authorization"] = "Bearer #{expired_token.token}"

        post endpoint, params: { results: [] }.to_json, headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with non-existent test run" do
      it "returns not found" do
        post "/api/v1/test_runs/999999/cypress_results",
             params: { results: [] }.to_json,
             headers: headers

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Not Found")
      end
    end
  end
end

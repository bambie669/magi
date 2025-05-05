require 'rails_helper'

RSpec.describe "TestRunCases", type: :request do
  describe "GET /update" do
    it "returns http success" do
      get "/test_run_cases/update"
      expect(response).to have_http_status(:success)
    end
  end

end

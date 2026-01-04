require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  let(:user) { create(:user, :admin) }

  describe "GET /dashboard" do
    context "when user is logged in" do
      before { sign_in user }

      it "returns http success" do
        get "/dashboard"
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not logged in" do
      it "redirects to login page" do
        get "/dashboard"
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end

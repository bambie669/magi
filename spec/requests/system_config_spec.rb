require 'rails_helper'

RSpec.describe "SystemConfig", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:manager) { create(:user, role: :manager) }
  let(:tester) { create(:user, role: :tester) }

  describe "GET /system_config" do
    context "when authenticated" do
      before { sign_in admin }

      it "returns success" do
        get system_config_path
        expect(response).to have_http_status(:success)
      end

      it "displays theme section by default" do
        get system_config_path
        expect(response.body).to include("Theme Settings")
      end

      it "displays documentation section when requested" do
        get system_config_path(section: 'documentation')
        expect(response.body).to include("System Overview")
      end

      it "displays glossary section when requested" do
        get system_config_path(section: 'glossary')
        expect(response.body).to include("Terminology Reference")
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get system_config_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /system_config/update_theme" do
    before { sign_in admin }

    it "updates user theme to dark" do
      patch update_theme_path, params: { theme: 'dark' }
      expect(admin.reload.theme).to eq('dark')
      expect(response).to redirect_to(system_config_path(section: 'theme'))
    end

    it "updates user theme to light" do
      patch update_theme_path, params: { theme: 'light' }
      expect(admin.reload.theme).to eq('light')
      expect(response).to redirect_to(system_config_path(section: 'theme'))
    end

    it "sets success flash message" do
      patch update_theme_path, params: { theme: 'light' }
      expect(flash[:notice]).to include('Theme preference updated')
    end
  end

  describe "GET /system_config/operators" do
    context "as admin" do
      before { sign_in admin }

      it "returns success" do
        get system_config_path(section: 'operators')
        expect(response).to have_http_status(:success)
      end

      it "displays user management" do
        get system_config_path(section: 'operators')
        expect(response.body).to include("User Management")
      end

      it "lists all users" do
        other_user = create(:user, email: 'other@company.com')
        get system_config_path(section: 'operators')
        expect(response.body).to include(admin.email)
        expect(response.body).to include(other_user.email)
      end
    end

    context "as non-admin" do
      before { sign_in tester }

      it "does not show users section content" do
        get system_config_path(section: 'operators')
        expect(response.body).not_to include("User Management")
      end
    end
  end

  describe "GET /system_config/operators/new" do
    context "as admin" do
      before { sign_in admin }

      it "returns success" do
        get new_operator_path
        expect(response).to have_http_status(:success)
      end

      it "displays new user form" do
        get new_operator_path
        expect(response.body).to include("Add New User")
      end
    end

    context "as non-admin" do
      before { sign_in tester }

      it "denies access" do
        get new_operator_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /system_config/operators" do
    let(:valid_params) do
      {
        user: {
          email: 'newuser@company.com',
          password: 'password123',
          password_confirmation: 'password123',
          role: 'tester'
        }
      }
    end

    context "as admin" do
      before { sign_in admin }

      it "creates a new user" do
        expect {
          post create_operator_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "redirects to users section" do
        post create_operator_path, params: valid_params
        expect(response).to redirect_to(system_config_path(section: 'operators'))
      end

      it "sets success flash" do
        post create_operator_path, params: valid_params
        expect(flash[:notice]).to include('User created')
      end

      it "fails with invalid params" do
        post create_operator_path, params: { user: { email: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "as non-admin" do
      before { sign_in tester }

      it "denies access" do
        expect {
          post create_operator_path, params: valid_params
        }.not_to change(User, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /system_config/operators/:id/edit" do
    let(:target_user) { create(:user, email: 'target@company.com') }

    context "as admin" do
      before { sign_in admin }

      it "returns success" do
        get edit_operator_path(target_user)
        expect(response).to have_http_status(:success)
      end

      it "displays edit form" do
        get edit_operator_path(target_user)
        expect(response.body).to include("Edit User")
        expect(response.body).to include(target_user.email)
      end
    end

    context "as non-admin" do
      before { sign_in tester }

      it "denies access" do
        get edit_operator_path(target_user)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH /system_config/operators/:id" do
    let(:target_user) { create(:user, email: 'target@company.com', role: :tester) }

    context "as admin" do
      before { sign_in admin }

      it "updates user email" do
        patch update_operator_path(target_user), params: { user: { email: 'updated@company.com' } }
        expect(target_user.reload.email).to eq('updated@company.com')
      end

      it "updates user role" do
        patch update_operator_path(target_user), params: { user: { role: 'manager' } }
        expect(target_user.reload.role).to eq('manager')
      end

      it "updates password when provided" do
        old_password = target_user.encrypted_password
        patch update_operator_path(target_user), params: {
          user: { password: 'newpassword123', password_confirmation: 'newpassword123' }
        }
        expect(target_user.reload.encrypted_password).not_to eq(old_password)
      end

      it "does not update password when blank" do
        old_password = target_user.encrypted_password
        patch update_operator_path(target_user), params: {
          user: { email: 'same@company.com', password: '', password_confirmation: '' }
        }
        expect(target_user.reload.encrypted_password).to eq(old_password)
      end

      it "redirects to users section" do
        patch update_operator_path(target_user), params: { user: { role: 'manager' } }
        expect(response).to redirect_to(system_config_path(section: 'operators'))
      end
    end

    context "as non-admin" do
      before { sign_in tester }

      it "denies access" do
        patch update_operator_path(target_user), params: { user: { role: 'admin' } }
        expect(response).to redirect_to(root_path)
        expect(target_user.reload.role).to eq('tester')
      end
    end
  end

  describe "DELETE /system_config/operators/:id" do
    let!(:target_user) { create(:user, email: 'target@company.com') }

    context "as admin" do
      before { sign_in admin }

      it "deletes the user" do
        expect {
          delete destroy_operator_path(target_user)
        }.to change(User, :count).by(-1)
      end

      it "redirects to users section" do
        delete destroy_operator_path(target_user)
        expect(response).to redirect_to(system_config_path(section: 'operators'))
      end

      it "prevents self-deletion" do
        expect {
          delete destroy_operator_path(admin)
        }.not_to change(User, :count)
        expect(flash[:alert]).to include('Cannot delete your own account')
      end
    end

    context "as non-admin" do
      before { sign_in tester }

      it "denies access" do
        expect {
          delete destroy_operator_path(target_user)
        }.not_to change(User, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  # API Tokens Section Tests
  describe "GET /system_config?section=api_tokens" do
    context "as admin" do
      before { sign_in admin }

      it "returns success" do
        get system_config_path(section: 'api_tokens')
        expect(response).to have_http_status(:success)
      end

      it "displays API tokens section" do
        get system_config_path(section: 'api_tokens')
        expect(response.body).to include("Create New API Token")
      end

      it "displays user's existing tokens" do
        token = create(:api_token, user: admin, name: 'My Test Token')
        get system_config_path(section: 'api_tokens')
        expect(response.body).to include('My Test Token')
      end
    end

    context "as tester" do
      before { sign_in tester }

      it "returns success" do
        get system_config_path(section: 'api_tokens')
        expect(response).to have_http_status(:success)
      end

      it "only shows tester's own tokens" do
        admin_token = create(:api_token, user: admin, name: 'Admin Token')
        tester_token = create(:api_token, user: tester, name: 'Tester Token')
        get system_config_path(section: 'api_tokens')
        expect(response.body).to include('Tester Token')
        expect(response.body).not_to include('Admin Token')
      end
    end

    context "as manager" do
      before { sign_in manager }

      it "returns success" do
        get system_config_path(section: 'api_tokens')
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /system_config/api_tokens" do
    context "as any authenticated user" do
      before { sign_in tester }

      it "creates a new API token" do
        expect {
          post create_api_token_path, params: { api_token: { name: 'Cypress Token' } }
        }.to change(ApiToken, :count).by(1)
      end

      it "associates token with current user" do
        post create_api_token_path, params: { api_token: { name: 'My Token' } }
        expect(ApiToken.last.user).to eq(tester)
      end

      it "redirects to api_tokens section" do
        post create_api_token_path, params: { api_token: { name: 'My Token' } }
        expect(response).to redirect_to(system_config_path(section: 'api_tokens'))
      end

      it "sets flash with new token value" do
        post create_api_token_path, params: { api_token: { name: 'My Token' } }
        expect(flash[:new_token]).to be_present
        expect(flash[:new_token].length).to eq(64)
      end

      it "fails with blank name" do
        expect {
          post create_api_token_path, params: { api_token: { name: '' } }
        }.not_to change(ApiToken, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "can set expiration date" do
        future_date = 30.days.from_now
        post create_api_token_path, params: {
          api_token: { name: 'Expiring Token', expires_at: future_date }
        }
        expect(ApiToken.last.expires_at).to be_within(1.second).of(future_date)
      end
    end

    context "as admin" do
      before { sign_in admin }

      it "creates token for admin" do
        expect {
          post create_api_token_path, params: { api_token: { name: 'Admin Token' } }
        }.to change { admin.api_tokens.count }.by(1)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        post create_api_token_path, params: { api_token: { name: 'Token' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /system_config/api_tokens/:id" do
    context "as token owner" do
      before { sign_in tester }

      it "deletes own token" do
        token = create(:api_token, user: tester)
        expect {
          delete destroy_api_token_path(token)
        }.to change(ApiToken, :count).by(-1)
      end

      it "redirects to api_tokens section" do
        token = create(:api_token, user: tester)
        delete destroy_api_token_path(token)
        expect(response).to redirect_to(system_config_path(section: 'api_tokens'))
      end

      it "sets success flash" do
        token = create(:api_token, user: tester)
        delete destroy_api_token_path(token)
        expect(flash[:notice]).to include('revoked')
      end
    end

    context "attempting to delete another user's token" do
      before { sign_in tester }

      it "does not delete another user's token" do
        admin_token = create(:api_token, user: admin)
        # set_api_token uses current_user.api_tokens.find which scopes to current user
        # This should either raise RecordNotFound or return 404
        expect {
          begin
            delete destroy_api_token_path(admin_token)
          rescue ActiveRecord::RecordNotFound
            # Expected behavior
          end
        }.not_to change(ApiToken, :count)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        token = create(:api_token, user: tester)
        delete destroy_api_token_path(token)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # Multi-role access tests
  describe "role-based access" do
    describe "theme section" do
      %i[admin manager tester].each do |role|
        context "as #{role}" do
          before { sign_in create(:user, role: role) }

          it "can access theme section" do
            get system_config_path(section: 'theme')
            expect(response).to have_http_status(:success)
            expect(response.body).to include("Theme Settings")
          end

          it "can update theme preference" do
            user = User.last
            patch update_theme_path, params: { theme: 'light' }
            expect(user.reload.theme).to eq('light')
          end
        end
      end
    end

    describe "documentation section" do
      %i[admin manager tester].each do |role|
        context "as #{role}" do
          before { sign_in create(:user, role: role) }

          it "can access documentation" do
            get system_config_path(section: 'documentation')
            expect(response).to have_http_status(:success)
            expect(response.body).to include("System Overview")
          end
        end
      end
    end

    describe "glossary section" do
      %i[admin manager tester].each do |role|
        context "as #{role}" do
          before { sign_in create(:user, role: role) }

          it "can access glossary" do
            get system_config_path(section: 'glossary')
            expect(response).to have_http_status(:success)
            expect(response.body).to include("Terminology Reference")
          end
        end
      end
    end

    describe "users section" do
      context "as admin" do
        before { sign_in admin }

        it "can access users section" do
          get system_config_path(section: 'operators')
          expect(response.body).to include("User Management")
        end
      end

      %i[manager tester].each do |role|
        context "as #{role}" do
          before { sign_in create(:user, role: role) }

          it "cannot see users content" do
            get system_config_path(section: 'operators')
            expect(response.body).not_to include("User Management")
          end
        end
      end
    end
  end
end

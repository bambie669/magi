class SystemConfigController < ApplicationController
  before_action :set_user, only: [:edit_user, :update_user, :destroy_user]
  before_action :set_api_token, only: [:destroy_api_token]

  # GET /system_config
  def index
    @section = params[:section] || 'theme'

    # Load operators data if needed
    if @section == 'operators' && current_user.admin?
      @users = User.order(:email)
      @pagy, @users = pagy(@users, items: 10)
    end

    # Load API tokens for current user
    if @section == 'api_tokens'
      @api_tokens = current_user.api_tokens.order(created_at: :desc)
      @new_api_token = ApiToken.new
    end
  end

  # GET /system_config/theme
  def theme
    @section = 'theme'
  end

  # PATCH /system_config/update_theme
  def update_theme
    if current_user.update(theme: params[:theme])
      respond_to do |format|
        format.html { redirect_to system_config_path(section: 'theme'), notice: 'Theme preference updated successfully.' }
        format.json { render json: { success: true, theme: current_user.theme } }
        format.any { head :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to system_config_path(section: 'theme'), alert: 'Failed to update theme preference.' }
        format.json { render json: { success: false, errors: current_user.errors.full_messages }, status: :unprocessable_entity }
        format.any { head :unprocessable_entity }
      end
    end
  end

  # GET /system_config/operators
  def operators
    authorize :system_config, :manage_operators?
    @section = 'operators'
    @users = User.order(:email)
    @pagy, @users = pagy(@users, items: 10)
  end

  # GET /system_config/operators/new
  def new_operator
    authorize :system_config, :manage_operators?
    @section = 'operators'
    @user = User.new
  end

  # POST /system_config/operators
  def create_operator
    authorize :system_config, :manage_operators?
    @user = User.new(user_params)

    if @user.save
      redirect_to system_config_path(section: 'operators'), notice: 'User created successfully.'
    else
      @section = 'operators'
      render :new_operator, status: :unprocessable_entity
    end
  end

  # GET /system_config/operators/:id/edit
  def edit_user
    authorize :system_config, :manage_operators?
    @section = 'operators'
  end

  # PATCH /system_config/operators/:id
  def update_user
    authorize :system_config, :manage_operators?

    update_params = user_params
    # Remove password fields if empty (don't update password)
    if update_params[:password].blank?
      update_params = update_params.except(:password, :password_confirmation)
    end

    if @user.update(update_params)
      redirect_to system_config_path(section: 'operators'), notice: 'User updated successfully.'
    else
      @section = 'operators'
      render :edit_user, status: :unprocessable_entity
    end
  end

  # DELETE /system_config/operators/:id
  def destroy_user
    authorize :system_config, :manage_operators?

    if @user == current_user
      redirect_to system_config_path(section: 'operators'), alert: 'Cannot delete your own account.'
    else
      @user.destroy
      redirect_to system_config_path(section: 'operators'), notice: 'User deleted successfully.'
    end
  end

  # GET /system_config/documentation
  def documentation
    @section = 'documentation'
  end

  # GET /system_config/glossary
  def glossary
    @section = 'glossary'
  end

  # POST /system_config/api_tokens
  def create_api_token
    @api_token = current_user.api_tokens.build(api_token_params)

    if @api_token.save
      # Store the token in flash so it can be displayed once
      flash[:new_token] = @api_token.token
      redirect_to system_config_path(section: 'api_tokens'), notice: 'API Token created successfully. Copy your token now - it will not be shown again.'
    else
      @section = 'api_tokens'
      @api_tokens = current_user.api_tokens.order(created_at: :desc)
      @new_api_token = @api_token
      render :index, status: :unprocessable_entity
    end
  end

  # DELETE /system_config/api_tokens/:id
  def destroy_api_token
    @api_token.destroy
    redirect_to system_config_path(section: 'api_tokens'), notice: 'API Token revoked successfully.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end

  def set_api_token
    @api_token = current_user.api_tokens.find(params[:id])
  end

  def api_token_params
    params.require(:api_token).permit(:name, :expires_at)
  end
end

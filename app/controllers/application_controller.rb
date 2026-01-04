class ApplicationController < ActionController::Base
    include Pundit::Authorization # Adaugă linia Pundit
    include Pagy::Backend
  
    protect_from_forgery with: :exception
    before_action :authenticate_user! # Forțează login pentru majoritatea paginilor
  
    # Configurează parametri permiși pentru Devise (dacă adaugi câmpuri custom)
    before_action :configure_permitted_parameters, if: :devise_controller?
  
    # Gestionează erorile de autorizare Pundit
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
    protected
  
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:role]) # Permite setarea rolului la înregistrare (deși poate vrei alt mecanism)
      devise_parameter_sanitizer.permit(:account_update, keys: [:role]) # Permite actualizarea rolului
    end
  
    private
  
    def user_not_authorized
      flash[:alert] = "Nu sunteți autorizat să efectuați această acțiune."
      redirect_back(fallback_location: root_path)
    end
  end
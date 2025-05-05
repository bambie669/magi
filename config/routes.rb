Rails.application.routes.draw do
  devise_for :users

  # Dashboard ca root pentru utilizatorii logați
  authenticated :user do
    root 'dashboard#index', as: :authenticated_root
  end

  # Pagina de login ca root pentru vizitatori
  devise_scope :user do
    root to: "devise/sessions#new"
  end

  get "dashboard", to: "dashboard#index"

  resources :projects do
    # Nested shallow: Doar index, new, create sunt sub /projects/:project_id/
    # Restul (show, edit, update, destroy) au URL propriu (/milestones/:id)
    resources :milestones
    resources :test_suites, shallow: true do
       resources :test_cases, shallow: true
    end
    resources :test_runs, shallow: true, except: [:edit, :update] # Folosim ruta separată pt update cazuri
  end

  # Rută specifică pentru actualizarea TestRunCase (status, comentarii, atașamente)
  resources :test_run_cases, only: [:update]

  # Ruta pentru health check
  get "up" => "rails/health#show", as: :rails_health_check
end
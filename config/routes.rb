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
    resources :test_runs, shallow: true do
      resources :test_run_cases, only: [:update]
   end
    resources :milestones, shallow: true
    resources :test_suites, shallow: true do
       resources :test_cases, shallow: true
    end
  end

  # Rută specifică pentru actualizarea TestRunCase (status, comentarii, atașamente)
  resources :test_run_cases, only: [:update]

  # Ruta pentru health check
  get "up" => "rails/health#show", as: :rails_health_check
end
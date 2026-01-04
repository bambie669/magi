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

  # Global search
  get "search", to: "search#index", as: :search

  # Analysis / Reports
  get "analysis", to: "analysis#index", as: :analysis

  # Notifications
  resources :notifications, only: [:index] do
    member do
      post :mark_as_read
    end
    collection do
      post :mark_all_as_read
    end
  end

  # Standalone test_runs index (shows all test runs across projects)
  resources :test_runs, only: [:index]

  resources :projects do
    resources :test_runs, shallow: true do
      member do
        get :export_csv
        get :export_pdf
      end
      resources :test_run_cases, only: [:update]
    end
    resources :milestones, shallow: true
    resources :test_suites, shallow: true do
      member do
        get :export_csv
        get :export_pdf
        get :import_csv
        post :process_import_csv
        get :csv_template
        delete :bulk_destroy_cases
        post :bulk_export_cases
      end
      resources :test_cases, shallow: true
    end
    resources :test_case_templates do
      member do
        get :apply
      end
    end
  end

  # Rută specifică pentru actualizarea TestRunCase (status, comentarii, atașamente)
  resources :test_run_cases, only: [:update]

  # API pentru integrări externe (Cypress, etc.)
  namespace :api do
    namespace :v1 do
      # Projects
      resources :projects, only: [:index, :show] do
        resources :test_runs, only: [:index, :create]
      end

      # Test Runs
      resources :test_runs, only: [:show, :update] do
        post 'cypress_results', to: 'cypress_results#create'
      end

      # Test Suites
      resources :test_suites, only: [] do
        resources :test_cases, only: [:index]
      end

      # Test Cases
      resources :test_cases, only: [:show]
      get 'test_cases/by_cypress_id/:cypress_id', to: 'test_cases#by_cypress_id'

      # Test Run Cases
      resources :test_run_cases, only: [:update]
      post 'test_run_cases/bulk_update', to: 'test_run_cases#bulk_update'
    end
  end

  # System Config
  get 'system_config', to: 'system_config#index', as: :system_config
  get 'system_config/theme', to: 'system_config#theme', as: :system_config_theme
  patch 'system_config/update_theme', to: 'system_config#update_theme', as: :update_theme
  get 'system_config/operators', to: 'system_config#operators', as: :system_config_operators
  get 'system_config/operators/new', to: 'system_config#new_operator', as: :new_operator
  post 'system_config/operators', to: 'system_config#create_operator', as: :create_operator
  get 'system_config/operators/:id/edit', to: 'system_config#edit_user', as: :edit_operator
  patch 'system_config/operators/:id', to: 'system_config#update_user', as: :update_operator
  delete 'system_config/operators/:id', to: 'system_config#destroy_user', as: :destroy_operator
  get 'system_config/documentation', to: 'system_config#documentation', as: :system_config_documentation
  get 'system_config/glossary', to: 'system_config#glossary', as: :system_config_glossary

  # API Tokens
  post 'system_config/api_tokens', to: 'system_config#create_api_token', as: :create_api_token
  delete 'system_config/api_tokens/:id', to: 'system_config#destroy_api_token', as: :destroy_api_token

  # Ruta pentru health check
  get "up" => "rails/health#show", as: :rails_health_check
end
Overmind::Application.routes.draw do
  devise_for :users do
    match "/login", :to => "devise/cas_sessions#new"
    match '/logout', to: "devise/cas_sessions#destroy"
  end
  resources :schools do
    resources :monthly_stats, except: [:show] do
      member do
        get 'sync'
      end
    end
    member do
      get 'sync_year'
    end
    collection do
      match "/pa/:account_name", to: 'schools#show_by_name'
    end
    resources :sync_requests, only: [:create, :update]
  end
  resource :ranking, only: [:show]
  resources :federations
  resources :users
  resources :monthly_stats, only: [] do
    collection do
      get 'global'
    end
  end

  namespace 'api' do
    namespace 'v0' do
      resources :monthly_stats
    end
  end

  root to: 'schools#index'
end

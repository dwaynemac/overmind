Overmind::Application.routes.draw do
  devise_for :users do
    match "/login", :to => "devise/cas_sessions#new"
    match '/logout', to: "devise/cas_sessions#destroy"
  end
  resources :schools do
    resources :reports, only: [] do
      collection do
        get 'pedagogic/:year/:month', to: 'reports#pedagogic_snapshot', as: :pdg
        get 'marketing/:year/:month', to: 'reports#marketing_snapshot', as: :mkt
        get ':return_to/:year/:month/refresh', to: 'reports#refresh', as: :refresh
      end
    end
    resources :monthly_stats, except: [:show] do
      member do
        get 'sync'
      end
      collection do
        get 'sync_create'
      end
    end
    member do
      get 'sync_year'
    end
    collection do
      match "/pa/:account_name", to: 'schools#show_by_name'
      match "/nid/:nid", to: 'schools#show_by_nucleo_id'
    end
    resources :sync_requests, only: [:create, :update]
    resource :teacher_ranking, only: [:show, :update]
  end
  resource :ranking, only: [:show, :update]
  resource :teacher_ranking, only: [:show, :update]
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
      resources :sync_requests, only: [] do
        collection do
          post :pause_all
        end
      end
    end
  end

 root to: 'schools#index'
 match 'message_door', to: 'message_door#catch'
 match 'sns', to: 'message_door#sns'
end

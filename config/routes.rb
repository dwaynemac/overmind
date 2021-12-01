Overmind::Application.routes.draw do
  devise_for :users do
    get "/login", :to => "sso_sessions#show"
    match '/logout', to: "sso_sessions_#destroy", via: [:get, :delete]
  end
  resource :sso_session
  get "/login", :to => "sso_sessions#show"
  match '/logout', to: "sso_sessions_#destroy", via: [:get, :delete]

  get "/formulario_ics", to: "ics#show", school_id: "current"
  get "/analytics", to: "rankings#history"

  resource :ics, only: [] do
    collection do
      get :select_school
    end
  end
  resources :reports, only: [] do
    collection do
      get 'global_teachers', to: 'reports#global_teachers'
    end
  end
  resources :schools do
    resources :teachers, only: [:show]
    resource :ics, only: [:show, :update]
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
      get "/pa/:account_name", to: 'schools#show_by_name'
      get "/pa/:account_name/ics", to: 'ics#show'
      get "/nid/:nid", to: 'schools#show_by_nucleo_id'
      get "/nid/:nucleo_id/ics", to: 'ics#show'
    end
    resources :sync_requests, only: [:create, :update]
    resource :teacher_ranking, only: [:show, :update]
  end
  resource :ranking, only: [:show, :update] do
    member do
      get 'students'
      get 'history'
    end
  end
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

 root to: 'rankings#show'
 get 'message_door', to: 'message_door#catch'
 get 'sns', to: 'message_door#sns'
 get "/ping", to: "ping#ping"

end

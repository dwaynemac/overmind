Overmind::Application.routes.draw do
  devise_for :users
  resources :schools do
    resources :monthly_stats, except: [:show] do
      member do
        get 'sync'
      end
    end
    member do
      get 'sync_year'
    end
  end
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

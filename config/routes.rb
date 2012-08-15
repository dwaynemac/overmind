Overmind::Application.routes.draw do
  devise_for :users
  resources :schools do
    resources :monthly_stats
  end
  resources :federations
  resources :users
  root to: 'schools#index'
end

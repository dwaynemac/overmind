Overmind::Application.routes.draw do
  devise_for :users
  resources :schools
  resources :users
  root to: 'schools#index'
end

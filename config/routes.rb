Talks::Application.routes.draw do
  devise_for :users

  resources :talks

  namespace :admin do
    get :index
  end
  
  root :to => "talks#index"
end

Talks::Application.routes.draw do
  resources :talks
  resources :lists
  devise_for :users

  namespace :admin do
    get :index
    resources :users, :only => [:index, :edit, :update, :destroy]
  end
  
  root :to => "talks#index"
end

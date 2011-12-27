Talks::Application.routes.draw do
  devise_for :users

  resources :talks

  namespace :admin do
    get :index
    resources :users, :only => [:index, :edit, :update, :destroy]
  end
  
  root :to => "talks#index"
end

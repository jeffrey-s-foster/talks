Talks::Application.routes.draw do
  resources :talks do
    get :upcoming
    member do
      get :subscribe
    end
  end

  resources :lists do
    member do
      get :subscribe
    end
  end

  namespace :buildings do
    get :index
    post :update
  end
  resources :buildings, :only => [:destroy]

  devise_for :users, :path_prefix => "profile"
  resources :users, :only => [:show]

  namespace :admin do
    get :index
    resources :users, :only => [:index, :edit, :update, :destroy]
  end
  
  root :to => "talks#upcoming"
end

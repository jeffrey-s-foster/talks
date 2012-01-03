Talks::Application.routes.draw do
  resources :talks do
    get :upcoming
    member do
      get :subscribe
      get :unsubscribe
    end
  end

  resources :lists do
    member do
      get :show_all
      get :subscribe
      get :unsubscribe
    end
  end

  devise_for :users, :path_prefix => "profile"
  resources :users, :only => [:show]

  namespace :admin do
    get :index
    resources :users, :only => [:index, :edit, :update, :destroy]
  end
  
  root :to => "talks#upcoming"
end

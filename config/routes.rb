Talks::Application.routes.draw do
  resources :talks do
    get :upcoming
  end

  resources :lists do
    member do
      get :show_all
    end
  end
  devise_for :users

  namespace :admin do
    get :index
    resources :users, :only => [:index, :edit, :update, :destroy]
  end
  
  root :to => "talks#upcoming"
end

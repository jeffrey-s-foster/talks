Talks::Application.routes.draw do
  resources :talks do
    get :upcoming
    member do
      get :subscribe
      get :calendar
    end
  end

  resources :lists do
    member do
      get :subscribe
      get :feed
    end
  end

  namespace :buildings do
    get :index
    post :update
  end
  resources :buildings, :only => [:destroy]

  devise_for :users, :path_prefix => "profile"
  resources :users, :only => [:index, :show, :edit, :update, :destroy] do
    member do
      get :feed
      get :reset_ical_secret
    end
  end

  namespace :admin do
    get :index
  end

  namespace :jobs do
    get :index
    match "delete/:id", :action => :delete, :via => [:delete], :as => :delete
    delete :delete_all
    get :do_stop
    get :do_restart
    get :do_reload
    get :do_status
  end
  
  root :to => "talks#upcoming"
end

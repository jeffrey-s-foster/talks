Talks::Application.routes.draw do
  devise_for :users

  resources :talks

  root :to => "talks#index"
end

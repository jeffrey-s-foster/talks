Talks::Application.routes.draw do
  resources :talks

  root :to => "talks#index"
end

Teachers::Engine.routes.draw do
  resources :teachers

  get "home/index"

  root :to => 'home#index'
end

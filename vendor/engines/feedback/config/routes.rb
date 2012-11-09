Feedback::Engine.routes.draw do
  resources :groups
  
  resources :messages do
    collection do
      get :sent
    end
  end

  root :to => 'messages#new'

end

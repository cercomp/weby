Feedback::Engine.routes.draw do
  constraints(Weby::Subdomain) do
    get 'admin' => 'admin/messages#index'

    namespace :admin do
      resources :groups
      resources :messages, only: [:index, :show, :destroy]
    end

    resources :messages, only: :create, path: '/'
  end

  root to: 'messages#new'
end

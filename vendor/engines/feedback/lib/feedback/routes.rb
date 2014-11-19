module Feedback
  module Routes
    def self.load(*args)
      Proc.new do
        namespace :admin, module: 'feedback/admin' do
          get :feedback, to: 'messages#index'
          resources :groups
          resources :messages, only: [:index, :show, :destroy]
        end
        get :feedback, to: 'feedback/messages#new'
        resources :messages, only: [:create, :index], module: 'feedback'
      end
    end
  end
end

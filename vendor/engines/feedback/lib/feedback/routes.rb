module Feedback
  module Routes
    def self.load(*args)
      Proc.new do
        namespace :admin, module: 'feedback/admin' do
          get :feedback, to: 'messages#index'
          resources :groups do
            collection do
              post :sort
              delete :destroy_many
            end
          end
          resources :messages, only: [:index, :show, :destroy] do
            collection do
              delete :destroy_many
            end
          end
        end
        get :feedback, to: 'feedback/messages#new'
        resources :messages, only: [:create, :index], module: 'feedback'
      end
    end
  end
end

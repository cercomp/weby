#Journal::Engine.routes.draw do
#
#  constraints(Weby::Subdomain) do
#
#    get 'admin' => 'admin/news#index'
#    namespace :admin do
#      resources :news do
#        member do
#          put :toggle, :recover
#        end
#        collection do
#          get :recycle_bin, :fronts
#        end
#      end
#    end
#
#    resources :news, only: [:show, :index]
#  end
#
#  root to: 'news#index'
#
#end
module Journal
  module Routes
    def self.load(*args)
      Proc.new do
        get 'admin/journal', to: 'journal/admin/news#index'
        namespace :admin, module: 'journal/admin' do
          resources :news do
            member do
              put :toggle, :recover
            end
            collection do
              get :recycle_bin, :fronts
            end
          end
        end
        resources :news, only: [:show, :index]
      end
    end
  end
end

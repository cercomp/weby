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
        namespace :admin, module: 'journal/admin' do
          get :journal, to: 'news#index'
          resources :news do
            member do
              put :toggle, :recover, :unshare
              get :newsletter, :share
              post :newsletter_histories
            end
            collection do
              get :recycle_bin, :fronts
              delete :empty_bin, :destroy_many
              post :sort, :update_draft, :cancel, :restore_draft
              patch :update_draft
            end
          end
          resources :newsletter_histories, only: [:index] do
            collection do
              get :pdf, :csv
            end
          end
          resources :newsletters, only: [:index, :destroy] do
            collection do
              delete :destroy_many
            end
          end
        end
        resources :news, module: :journal, path: 'n', only: [:show] do
          collection do
            post :sort
          end
        end
        get :news, to: 'journal/news#index', as: :news_index
        get '/feed' => 'journal/news#index', as: :site_feed,
            defaults: { format: 'rss', per_page: 10 }
        resources :newsletters, module: :journal, only: [:new, :show]
      end
    end
  end
end

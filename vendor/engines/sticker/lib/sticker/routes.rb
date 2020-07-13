module Sticker
  module Routes
    def self.load(*args)
      Proc.new do
        namespace :admin, module: 'sticker/admin' do
          get :sticker, to: 'banners#index'
          resources :banners do
            member do
              get :share_modal, :share
              put :toggle, :unshare
            end
            collection do
              get :fronts
              post :sort
              delete :destroy_many
            end
          end
        end
        # json route - API Rest
        get :banners, to: 'sticker/banners#index', as: :banners_index
      end
    end
  end
end

module Sticker
  module Routes
    def self.load(*args)
      Proc.new do
        namespace :admin, module: 'sticker/admin' do
          get :sticker, to: 'banners#index'
          resources :banners do
            member do
              put :toggle
            end
            collection do
              get :fronts
            end
          end
        end
      end
    end
  end
end

Sticker::Engine.routes.draw do
  constraints(Weby::Subdomain) do
    get 'admin' => 'admin/banners#index'

    namespace :admin do
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

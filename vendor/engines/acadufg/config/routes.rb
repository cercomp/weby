Acadufg::Engine.routes.draw do
  constraints(Weby::Subdomain) do
    get 'admin' => 'admin/settings#show'

    namespace :admin do
      resource :setting, except: [:new, :edit, :destroy]
    end
  end

  root to: 'acadufg#index'
end

Acadufg::Engine.routes.draw do
  constraints(Weby::Subdomain) do
    get 'admin' => 'admin/acadufg#index'
    
    namespace :admin do
      resource :acadufg
    end
  end
  root :to => 'acadufg#index'
end

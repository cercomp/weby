Webyge3::Application.routes.draw do |map|
  resources :site do
    resources :menus
    resources :eventos
    resources :noticias
    resources :informativos
    resources :pages
    resources :chats
    resources :admin, :controller => "admin", :only => [:index]
    resources :roles
    resources :rights
    resources :users
  end

  resources :sites
  resources :menus
  resources :eventos
  resources :noticias
  resources :informativos
  resources :pages
  resources :chats
  resources :admin, :controller => "admin", :only => [:index]
  resources :roles
  resources :rights

  resources :user_sessions
  resources :password_resets
  resources :account, :controller => "users"

  resources :users do
    collection do
      get :change_roles
    end
  end

  match 'logout' => 'user_sessions#destroy', :as => "logout"
  match 'login' => 'user_sessions#new', :as => 'login'
  match 'denied' => "admin#access_denied", :as => 'denied'
  match 'admin' => "admin#index"
  match ':site' => "sites#index" # Página principal do site

  root :to => "sites#index" # Página agregadora dos sites

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  match ':site(/:controller(/:action(/:id)))', :constraints => {
    :site       => /[a-z]*/, # Nenhuma ou mais letras minúsculas
    :controller => /[a-z_]+/, # Uma ou mais letras minúsculas e sublinhado
    :action     => /[a-z]*/,
    :id => /\d*/ # Nenhuma ou mais números
  } 
  match ':controller(/:action(/:id(.:format)))'
end

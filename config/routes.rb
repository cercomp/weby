Webyge3::Application.routes.draw do |map|
  resources :users do collection { get :change_roles } end

  match 'site/new' => "sites#new"
  match 'site/:site_id' => "sites#index"#, :constraints => {:site_id => /\d/}

  resources :site do
    resources :menus do collection { get :rm_menu } end
    resources :eventos
    resources :noticias
    resources :informativos
    resources :groups
    resources :feedbacks
    resources :pages
    resources :chats
    resources :admin, :controller => "admin", :only => [:index]
    resources :roles
    resources :rights
    resources :users do collection { get :change_roles } end
  end

  resources :sites
  resources :groups
  resources :feedbacks
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

  match 'logout' => 'user_sessions#destroy', :as => "logout"
  match 'login' => 'user_sessions#new', :as => 'login'
  match 'denied' => "admin#access_denied", :as => 'denied'
  match 'admin' => "admin#index"

  root :to => "sites#index" # Página agregadora dos sites

  match 'site/:site_id(/:controller(/:action(/:id)))', :constraints => {
    :site       => /[a-z]*/, # Nenhuma ou mais letras minúsculas
    :controller => /[a-z_]+/, # Uma ou mais letras minúsculas e sublinhado
    :action     => /[a-z]*/,
    :id => /\d*/ # Nenhuma ou mais números
  } 
  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'
end

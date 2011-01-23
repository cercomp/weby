Webyge::Application.routes.draw do |map|

  resources :groups
  resources :feedbacks
  resources :menus
  resources :pages
  resources :chats
  resources :admin, :controller => "admin", :only => [:index]
  resources :roles
  resources :rights
  resources :archives
  resources :user_sessions
  resources :password_resets
  resources :account, :controller => "users"
  resources :admin, :controller => "users"
  resources :users do
    collection do
      get :manage_roles
      post :change_roles
    end
  end
  resources :repositories do
    collection do
     get :manage
    end
  end
  resources :users do
    collection do
      get :manage_roles
    end
  end
  resources :attachments do
    collection do
     get :manage
    end
  end

  match ':sites/:site_id(/:controller(/:action(/:id)))', 
    :controller => "sites",
    :action => /[a-z]*/
#    :site_id => /[a-z]*/ # Nenhuma ou mais letras minúsculas
#    :controller => /[a-z_]+/, # Uma ou mais letras minúsculas e sublinhado
#    :id => /\d*/ # Nenhuma ou mais números

  resources :sites do
   resources :admin, :controller => "users"
   resources :admin do
      collection do
        get :manage_roles
        post :change_roles
      end
    end
    resources :repositories do
      collection do
       get :manage
      end
    end
    resources :menus do 
      collection do 
        get :rm_menu, :change_position, :to_site
        post :link_site, :unlink_site
      end 
    end
    
    resources :groups
    resources :feedbacks
    resources :pages
    resources :chats
    resources :roles
    resources :rights
    resources :archives
  end

  match 'logout' => 'user_sessions#destroy', :as => "logout"
  match 'login' => 'user_sessions#new', :as => 'login'
  match 'denied' => "admin#access_denied", :as => 'denied'

  root :to => "sites#index" # Página agregadora dos sites

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  #match ':controller(/:action(/:id(.:format)))'
end

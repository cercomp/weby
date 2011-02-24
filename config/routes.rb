Webyge::Application.routes.draw do |map|

  match "sites/:site_id" => 'pages#view', :via => :get, :constraints => {:site_id => /#{Site.all.map{|p| p.name}.join('|')}/}

  resources :sites do
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
    resources :menus do 
      collection do 
        get :rm_menu, :change_position, :to_site
        post :link_site, :unlink_site
      end 
    end
    resources :banners do 
      member do 
        get :toggle_field
      end 
    end
    resources :pages do 
      member do 
        get :toggle_field
      end 
      collection do
        post :sort
        get :view
      end
    end

    resources :feedbacks do
      collection do
        get :sent
      end
    end

    resources :csses do
      member do
        get :use_css
      end
    end

    resources :groups, :chats, :roles, :rights, :archives, :admin
  end

  resources :groups, :menus, :chats, :rights, :archives, :user_sessions, :password_resets, :admin, :csses

  resources :account, :controller => "users"
  resources :roles do
    collection do
      put :index
    end
  end
  resources :users do
    collection do
      get :manage_roles
      post :change_roles
    end
    member do 
      get :toggle_field
    end 
  end
  resources :repositories do
    collection do
     get :manage
    end
  end
  resources :attachments do
    collection do
     get :manage
    end
  end

  match 'logout' => 'user_sessions#destroy', :as => "logout"
  match 'login' => 'user_sessions#new', :as => 'login'
  match 'denied' => "admin#access_denied", :as => 'denied'

  root :to => "sites#index" # Página agregadora dos sites

  match ':sites/:site_id(/:controller(/:action(/:id)))', :controller => 'sites',
    :constraints => {:site_id => /[^new|index|show|edit|update|destroy]/}

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  #match ':controller(/:action(/:id(.:format)))'
end

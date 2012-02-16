Weby::Application.routes.draw do
  # Para ativação de conta por email
  match 'activate(/:activation_code)' => 'users#activate', :as => :activate_account
  match 'send_activation(/:user_id)' => 'users#send_activation', :as => :send_activation

  #match '/page/:page' => 'sites#index' # Paginate URL on sites
  match '/sites/:site_id/users/page/:page' => 'users#index' # Paginate URL on users
  match '/sites/:site_id/pages/paginate/:paginate' => 'pages#index' # Paginate URL on pages
  match '/sites/:site_id/banners/page/:page' => 'banners#index' # Paginate URL on banners
  match '/sites/:site_id/repositories/page/:page' => 'repositories#index' # Paginate URL on repositories
  match '/sites/:site_id/groups/page/:page' => 'groups#index' # Paginate URL on groups


  resources :sites do
    collection do
      post :sort
    end
    resources :users do
      collection do
        get :manage_roles
        post :change_roles
      end
      member do 
        get :toggle_field
        get :set_admin
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
        post :link_site, :unlink_site, :change_order, :change_category
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
        get :add_i18n
        get :add_related_files
        post :create_i18n
      end 
      collection do
        post :sort
        get :list_published, :list_front
      end
    end
    resources :site_components do
      member do
        get :toggle_field
      end
      collection do
        post :sort
      end
    end
    resources :feedbacks do
      collection do
        get :sent
      end
    end
    resources :csses do
      member do
        get :copy, :follow, :toggle_field
      end
    end
    resources :roles do
      collection do
        put :index
      end
    end

    resources :groups, :chats, :rights, :archives, :admin
  end

  resources :groups, :chats, :rights, :archives, :user_sessions, :admin, :settings
  resources :password_resets, :only => [ :new, :create, :edit, :update ]
  resources :account, :controller => "users"
  resources :users do
    collection do
      get :manage_roles
      post :change_roles
    end
    member do 
      get :toggle_field
      get :set_admin
    end 
  end
  resources :roles do
    collection do
      put :index
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
  match '*a', :to => 'application#catcher'

end



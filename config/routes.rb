Weby::Application.routes.draw do
  # TODO: desfazer o alias de account e passar tudo para users
  # TODO: mudar de onde era o admin para seu respectivo controller, mudou para namespace
  # TODO: Verificar se attachments é necessário para o tinymce, se não remover
  
  # refactored
  root :to => "sites#index"
  
  resources :user_sessions
  
  resources :sites,
    only: [:index, :show] do
    resources :banners,
      controller: 'sites/banners', 
      only: [:index, :show]
    resources :components, 
      controller: 'sites/components', 
      only: [:index, :show]
    resources :groups, 
      controller: 'sites/groups', 
      only: [:index, :show]
    resources :pages, 
      controller: 'sites/pages', 
      only: [:index, :show]
    resources :repositories, 
      controller: 'sites/repositories', 
      only: [:index, :show]
    resources :rights, 
      controller: 'sites/rights', 
      only: [:index, :show]
    resources :roles, 
      controller: 'sites/roles', 
      only: [:index, :show]
    resources :styles, 
      controller: 'sites/styles', 
      only: [:index, :show]
    resources :users, 
      controller: 'sites/users', 
      only: [:index, :show]
    resources :feedbacks, 
      controller: 'sites/feedbacks', 
      only: [:index, :show] do
      collection do
        get :sent
      end
    end
    resources :menus, 
      controller: 'sites/menus', 
      only: [:index, :show] do
      resources :menu_items, 
        controller: 'sites/menus/menu_items', 
        only: [:index, :show]
    end
    namespace :admin, module: 'sites/admin' do
      resources :rights
      resources :feedbacks
      resources :groups
      resources :banners do
        member do 
          put :toggle_field
        end 
      end
      resources :components do
        member do
          put :toggle_field
        end
        collection do
          post :sort
        end
      end
      resources :menus do
        resources :menu_items,
          controller: 'menus/menu_items', 
          except: :show do
          collection do
            post :change_order, :change_menu
          end
        end
      end
      resources :pages do
        member do 
          put :toggle_field
        end 
        collection do
          get :published, :fronts
          post :sort
        end
      end
      resources :repositories do
        collection do
          get :manage
        end
      end
      resources :roles do
        collection do
          put :index
        end
      end
      resources :styles do
        member do
          get :copy, :follow, :unfollow, :publish, :unpublish
        end
      end
      resources :users do 
        collection do
          get :manage_roles
          post :change_roles
        end
        member do 
          put :toggle_field
        end 
      end
    end
  end
  
  namespace :admin do
    resources :rights
    resources :settings
    resources :password_resets, 
      only: [ :new, :create, :edit, :update ]
    resources :users do
      collection do
        get :manage_roles
        post :change_roles
      end
      member do 
        put :toggle_field
        get :set_admin
      end 
    end
    resources :roles do
      collection do
        put :index
      end
    end
    resources :sites do
      collection do
        post :sort
      end
      #resources :rights, 
      #  controller: 'sites/rights'
      #resources :feedbacks, 
      #  controller: 'sites/feedbacks'
      #resources :groups, 
      #  controller: 'sites/groups'
      #resources :banners,
      #  controller: 'sites/banners' do
      #  member do 
      #    put :toggle_field
      #  end 
      #end
      #resources :components,
      #  controller: 'sites/components' do
      #  member do
      #    put :toggle_field
      #  end
      #  collection do
      #    post :sort
      #  end
      #end
      #resources :menus,
      #  controller: 'sites/menus' do
      #  resources :menu_items,
      #    controller: 'sites/menus/menu_items',
      #    except: :show do
      #    collection do
      #      post :change_order, :change_menu
      #    end
      #  end
      #end
      #resources :pages, 
      #  controller: 'sites/pages' do
      #  member do 
      #    put :toggle_field
      #  end 
      #  collection do
      #    get :published, :fronts
      #    post :sort
      #  end
      #end
      #resources :repositories, 
      #  controller: 'sites/repositories' do
      #  collection do
      #    get :manage
      #  end
      #end
      #resources :roles, 
      #  controller: 'sites/roles' do
      #  collection do
      #    put :index
      #  end
      #end
      #resources :styles, 
      #  controller: 'sites/styles' do
      #  member do
      #    get :copy, :follow, :unfollow, :publish, :unpublish
      #  end
      #end
      #resources :users, 
      #  controller: 'sites/users' do
      #  collection do
      #    get :manage_roles
      #    post :change_roles
      #  end
      #  member do 
      #    put :toggle_field
      #  end 
      #end
    end
  end

  # legacy, verificar a possibilidade de refatoração

  # routes to login, logout and denied access
  match 'logout' => 'user_sessions#destroy', :as => "logout"
  match 'login' => 'user_sessions#new', :as => 'login'
  match 'denied' => "admin#access_denied", :as => 'denied'

  # WTF???
  match '*a', :to => 'application#catcher'

  # Para ativação de conta por email
  match 'activate(/:activation_code)' => 'users#activate', 
    as: :activate_account
  match 'send_activation(/:user_id)' => 'users#send_activation', 
    as: :send_activation

  # routes to feed and atom
  match '/sites/:site_id/feed' => 'pages#published', 
    as: :feed, defaults: { format: 'rss', per_page: 10, page: 1 }
  match '/sites/:site_id/atom' => 'pages#published', 
    as: :atom, defaults: { format: 'atom', per_page: 10, page: 1 }

  # route to paginate
  match '/sites/:site_id/users/page/:page' => 'users#index'
  match '/sites/:site_id/banners/page/:page' => 'banners#index'
  match '/sites/:site_id/repositories/page/:page' => 'repositories#index'
  match '/sites/:site_id/groups/page/:page' => 'groups#index'

  # TinyMCE??
  #resources :attachments do
  #  collection do
  #    get :manage
  #  end
  #end
end

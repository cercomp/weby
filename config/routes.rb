Rails.application.routes.draw do
  constraints(Weby::Subdomain) do

    get '/' => 'sites#show', as: :site
    get '/admin' => 'sites#admin', as: :site_admin
    get '/admin/edit' => 'sites#edit', as: :edit_site_admin
    get '/map' => 'sites/pages#sitemap', as: :sitemap_site_pages
    patch '/admin/edit' => 'sites#update', as: :update_site_admin
    delete '/admin/subsites/:id' => 'sites#destroy_subsite', as: :destroy_subsite_admin
    patch '/admin/subsites/:id' => 'sites#update_subsite', as: :update_subsite_admin

    resources :pages, as: :site_pages, controller: 'sites/pages', path: 'p', only: [:show]
    get '/fp', to: 'sites/pages#frame'
    get :pages, to: 'sites/pages#index', as: :site_pages
    get '/search', to: 'sites/searches#index', as: :searches
    #old routes
    get 'pages/:id(-:title)' => 'sites/pages#redirect', constraints: {id: /\d+/}

    resources :components,
              as: :site_components,
              controller: 'sites/components',
              only: [:show]

    post 'count/:model/:id' => 'application#count_click', as: :count_click

    namespace :admin, module: 'sites/admin', as: :site_admin do

      # route to paginate
      get 'repositories/page/:page' => 'repositories#index'
      get 'pages/page/:page' => 'pages#index'

      get 'stats' => 'statistics#index'
      get 'backups' => 'backups#index'
      get 'generate' => 'backups#generate'
      post 'import' => 'backups#import'

      resources :activity_records, only: [:index, :show]
      resources :extensions
      resources :menus do
        collection do
          post :change_order
        end
        resources :menu_items, controller: 'menus/menu_items' do
          member do
            put :toggle
          end
          collection do
            post :change_order, :change_menu
            delete :destroy_many
          end
        end
      end
      resources :pages do
        member do
          put :toggle, :recover
        end
        collection do
          get :recycle_bin
          delete :empty_bin, :destroy_many
        end
      end
      resources :repositories do
        member do
          get :crop
          put :recover
        end
        collection do
          get :recycle_bin
          delete :empty_bin, :destroy_many
        end
      end
      resources :roles, except: [:show] do
        collection do
          put :index
        end
      end
      resources :skins do
        member do
          post :apply
          get :preview
        end
        resources :components do
          member do
            put :toggle
            post :clone
          end
          collection do
            post :sort
            delete :destroy_many
          end
        end
        resources :styles do
          member do
            put :toggle, :copy, :follow, :unfollow
          end
          collection do
            post :sort
            delete :destroy_many
          end
        end
      end
      resources :users, only: [] do
        collection do
          get :manage_roles, :search
          post :change_roles, :create_local_admin_role, :set_preferences
          delete :destroy_local_admin_role
        end
      end
      resources :layouts, only: [] do
        collection do
          get :settings
          patch :settings, action: "update_settings"
        end
      end
    end

    Weby.extensions.each do |name, extension|
      constraints(extension) do
        require "#{name.to_s}/routes"
        instance_eval &("#{name.to_s.classify}::Routes".constantize.load)
      end
    end
  end

  root to: 'sites#index'

  constraints(Weby::GlobalDomain) do
    # route to paginate
    get 'sites/page/:page' => 'sites#index', as: :sites

    get '/admin' => 'application#admin'

    namespace :admin do
      match 'settings' => 'settings#index', via: [:get, :put]
      post 'settings/exec' => 'settings#exec', as: :exec
      resources :users do
        collection do
          get :manage_roles, :search
          post :change_roles
        end
        member do
          put :toggle
          put :set_admin
        end
      end
      resources :roles, except: :show do
        collection do
          put :index
          post :sort
        end
      end
      resources :sites, except: [:show] do
        member do
          put :toggle
          post :reindex
        end
      end
      resources :groupings, except: [:show]
      resources :notifications
      resources :activity_records, only: [:index, :show, :destroy]

      get 'stats' => 'statistics#index'

      # route to paginate
      get 'users/page/:page' => 'users#index'
      get 'sites/page/:page' => 'sites#index'
    end
  end

  # routes to profiles
  resources :profiles, only: [:show, :edit, :update], constraints: {id: /[^\/]+/} do
    member do
      get :history
    end
  end

  resources :notifications, only: [:index, :show] do
    collection do
      post :mark_as_read
    end
  end

  # defaults devise routes
  devise_for :users,
    path: '/',
    skip: [:sessions, :registrations, :passwords],
    controllers: { omniauth_callbacks: 'omniauth_callbacks' }

  # customize devise routes
  devise_scope :user do
    # routes to session
    delete 'logout'  => 'sessions#destroy'
    get 'login'   => 'sessions#new'
    post 'login'   => 'sessions#create'
    post 'link_user' => 'sessions#link_user'
    get 'new_user' => 'sessions#new_user'
    get 'shib_login/:hash' => 'sessions#shib_login', as: :shib_login

    # routes to register
    get 'signup'  => 'devise/registrations#new'
    post 'signup'  => 'registrations#create'

    # routes to password
    get 'forgot_password' => 'devise/passwords#new'
    post 'forgot_password' => 'passwords#create'
    get 'reset_password'  => 'devise/passwords#edit'
    put 'reset_password'  => 'devise/passwords#update'
  end

  get 'robots.txt' => 'sites#robots', format: 'txt'
  get '*not_found' => 'application#render_404'
end

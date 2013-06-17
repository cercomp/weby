Weby::Application.routes.draw do
  constraints(Weby::Subdomain) do
    constraints(Weby::Extensions) do
      # Mount all engines here
      mount Feedback::Engine, :at => 'feedback'
      mount Acadufg::Engine, :at => 'acadufg'
    end

    get '/' => 'sites#show', as: :site
    get '/admin' => 'sites#admin', as: :site_admin
    get '/admin/edit' => 'sites#edit', as: :edit_site_admin
    put '/admin/edit' => 'sites#update', as: :edit_site_admin

    # routes to feed and atom
    match '/feed' => 'sites/pages#published', as: :site_feed,
      defaults: { format: 'rss', per_page: 10, page: 1 }
    # route to paginate
    match 'admin/banners/page/:page' => 'sites/admin/banners#index'

    resources :pages,
      as: :site_pages, 
      controller: "sites/pages", 
      only: [:index, :show] do
        collection do
          get :published, :events, :news
          post :sort
        end
      end

    resources :components,
      as: :site_components,
      controller: 'sites/components',
      only: [:show]

    post "count/:model/:id" => "application#count_click", :as => :count_click

    namespace :admin, module: 'sites/admin', as: :site_admin do

      # route to paginate
      match "banners/page/:page" => "banners#index"
      match "groups/page/:page" => "groups#index"
      match "repositories/page/:page" => "repositories#index"
      match "pages/page/:page" => "pages#index"

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
      resources :extensions
      resources :menus do
        resources :menu_items,
          controller: "menus/menu_items",
          except: :show do
            collection do
              post :change_order, :change_menu
            end
          end
      end
      resources :pages do
        member do
          put :toggle_field, :share
          get :share_prompt
        end
        collection do
          get :fronts
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
        collection do
          post :sort
        end
      end
      resources :users, only: [] do
        collection do
          get :manage_roles
          post :change_roles
        end
      end
    end
  end

  root :to => "sites#index"

  #rota para paginação
  match "sites/page/:page" => "sites#index"

  constraints(Weby::GlobalDomain) do
    match "/admin" => "application#admin"

    namespace :admin do
      resources :settings, except: :show
      resources :users do
        collection do
          get :manage_roles
          post :change_roles
        end
        member do
          put :toggle_field
          put :set_admin
        end
      end
      resources :roles, except: :show do
        collection do
          put :index
          post :sort
        end
      end
      resources :sites, except: [:show]

      get "stats" => "statistics#index", :as => :stats

      # route to paginate
      match "users/page/:page" => "users#index"
      match "sites/page/:page" => "sites#index"
    end

    # clipping
    get "/clipping" => "clipping#index", as: :clipping
  end

  # routes to session
  match "logout"  => "session#logout"
  get   "login"   => "session#login"
  post  "login"   => "session#create_session"
  get   "signup"  => "session#login"
  post  "signup"  => "session#create_user"

  # routes to forget password
  match "forgot_password" => "session#forgot_password"
  match "password_sent"   => "session#password_sent"
  get   "reset_password"  => "session#reset_password"
  post  "update_password" => "session#update_password"

  # Para ativação de conta por email
  match "activate(/:activation_code)" => "session#activate_user", as: :activate_account
  post  "resend_activation" => "session#resend_activation"

  get "about" => "sites#about"
  match "robots.txt" => "sites#robots", :format => "txt"
  match "*not_found" => "application#render_404"
end

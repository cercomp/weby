Weby::Application.routes.draw do
  constraints(Weby::Subdomain) do
    get "/" => "sites#show", as: :site
    get "/admin" => "sites#admin", as: :site_admin
    get "/admin/edit" => "sites#edit", as: :edit_site_admin
    put "/admin/edit" => "sites#update", as: :edit_site_admin

    # routes to feed and atom
    match "/feed" => "sites/pages#published", as: :site_feed,
      defaults: { format: "rss", per_page: 10, page: 1 }
  
    # route to paginate
    match "admin/banners/page/:page" => "sites/admin/banners#index"
    match "admin/groups/page/:page" => "sites/admin/groups#index"

    resources :pages,
      as: :site_pages, 
      controller: "sites/pages", 
      only: [:index, :show] do
      collection do
        get :published, :events, :news
        post :sort
      end
    end

    resources :feedbacks,
      as: :site_feedbacks,
      controller: "sites/feedbacks", 
      only: [:new, :create] do
      collection do
        get :sent
      end
    end

    namespace :admin, module: "sites/admin", as: :site_admin do
      resources :feedbacks, except: [:new, :create]
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
          controller: "menus/menu_items",
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
      resources :users,
        only: [] do
        collection do
          get :manage_roles
          post :change_roles
        end
      end
    end
  end
  
  root :to => "sites#index"

  constraints(Weby::GlobalDomain) do
    match "/admin" => "application#admin"
    namespace :admin do
      resources :rights
      resources :settings,
        except: :show
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
      resources :roles,
        except: :show do
        collection do
          put :index
        end
        collection do
          post :sort
        end
      end
      resources :sites, except: [:show]
      
      # route to paginate
      match "admin/users/page/:page" => "admin/users#index"
    end 
  end

  # routes to session
  get "login"   => "session#new"
  post  "login" => "session#create"
  match "logout"  => "session#destroy"
  
  # routes to forget password
  match "forgot_password" => "session#forgot_password"
  match "password_sent"   => "session#password_sent"
  get "reset_password"  => "session#reset_password"
  post  "update_password" => "session#update_password"

  # Para ativação de conta por email
  match "activate(/:activation_code)" => "admin/users#activate",
    as: :activate_account

  match "robots.txt" => "sites#robots", :format => "txt"
  match "*not_found" => "application#render_404"
end

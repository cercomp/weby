module Calendar
  module Routes
    def self.load(*args)
      Proc.new do
        namespace :admin, module: 'calendar/admin' do
          get :calendar, to: 'events#index'
          resources :events do
            member do
              put :recover
            end
            collection do
              get :recycle_bin
              delete :empty_bin, :destroy_many
            end
          end
        end
        resources :events, module: 'calendar', path: 'e', only: [:show]
        get :events, to: 'calendar/events#index'
        get :calendar, to: 'calendar/events#calendar'
      end
    end
  end
end

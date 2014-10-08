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
            end
          end
        end
        resources :events, module: 'calendar', only: [:show, :index]
      end
    end
  end
end

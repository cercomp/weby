module Acadufg
  module Routes
    def self.load(*args)
      Proc.new do
        namespace :admin, module: 'acadufg/admin' do
          get :acadufg, to: 'settings#show'
          resource :setting, except: [:new, :edit, :destroy]
        end
      end
    end
  end
end

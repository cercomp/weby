Rails.application.routes.draw do

  mount Journal::Engine => "/journal"
end

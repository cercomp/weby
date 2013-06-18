Rails.application.routes.draw do

  mount Feedback::Engine => "/feedback"
end

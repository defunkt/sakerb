ActionController::Routing::Routes.draw do |map|
  map.resources :users, :has_many => :tasks
  map.resource :session
end

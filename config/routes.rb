ActionController::Routing::Routes.draw do |map|
  map.resources :tasks
  map.resources :users#, :has_many => :tasks
  map.resource :session
end

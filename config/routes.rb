ActionController::Routing::Routes.draw do |map|
  map.resources :tasks, :users
  map.resource :session

  map.home '', :controller => 'tasks', :action => :index
end

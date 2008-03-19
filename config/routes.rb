ActionController::Routing::Routes.draw do |map|
  map.resources :tasks, :member => { :favorite => :post }
  map.resources :users
  map.resource :session

  map.home '', :controller => 'tasks', :action => :index
end

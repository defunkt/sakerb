ActionController::Routing::Routes.draw do |map|
  map.resources :tasks, :member => { :favorite => :post }
  map.resources :users, :has_many => :favorites
  map.resource :session

  map.login '/login', :controller => 'sessions', :action => :new
  map.home '',        :controller => 'tasks', :action => :index
end

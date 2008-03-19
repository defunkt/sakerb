class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all 

  protect_from_forgery 
end

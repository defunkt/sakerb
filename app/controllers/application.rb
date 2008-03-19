class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all 

  protect_from_forgery 

  if Rails.development?
    def current_user
      @current_user ||= User.find(:first)
    end
  end
end

class FavoritesController < ApplicationController
  def index
    render :template => 'tasks/index'
  end

private
  helper_method :current_tasks

  def current_tasks
    current_user.favorites
  end
end

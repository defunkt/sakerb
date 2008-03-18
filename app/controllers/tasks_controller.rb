class TasksController < ApplicationController
  def index
  end

private
  helper_method :current_tasks

  def current_tasks
    @current_tasks ||= Task.recent
  end
end

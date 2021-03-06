class TasksController < ApplicationController
  def index
  end

  def show
    respond_to do |wants|
      wants.html
      wants.rb do
        current_task.add_view
        render :text => current_task.body
      end
    end
  end

  def favorite
    current_user.toggle_favorite current_task if logged_in?

    respond_to do |wants|
      wants.html do 
        redirect_to task_path(current_task) 
      end

      wants.js do
        render :nothing => true, :status => (logged_in? ? 200 : 401)
      end
    end
  end

private
  helper_method :current_tasks, :current_task

  def current_tasks
    @current_tasks ||= Task.recent
  end

  def current_task
    @current_task ||= Task.find(params[:id])
  end
end

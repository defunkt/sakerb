require File.dirname(__FILE__) + '/../test_helper'

context "TasksController" do
  scenario :default
  use_controller TasksController

  specify "displays recent tasks" do
    get :index

    Task.recent.each do |task|
      body['.tasks'].to_s.should.include task.name
    end
  end
end

context "Showing a task" do
  scenario :default
  use_controller TasksController
  
  setup do
    get :show, :id => simple_task.id
  end

  specify "displays the task body" do
    body['#main'].should.include simple_task.body
  end

  specify "displays the task name" do
    body['#main'].should.include simple_task.name
  end

  specify "displays the task's author" do
    body['#main'].should.include simple_task.user.login
  end
end

context "Showing a task (.rb)" do
  scenario :default
  use_controller TasksController

  setup do
    get :show, :id => simple_task.id, :format => 'rb'
  end

  specify "shows only the task's body" do
    body.should == simple_task.body
  end

  specify "sends the correct content-type" do
    assert_content_type 'text/plain'
  end

  specify "records a view" do
    Task.any_instance.expects(:add_view)

      get :show, :id => simple_task.id, :format => 'rb'

  end
end

context "Favoriting a task when logged in" do
  scenario :default
  use_controller TasksController

  setup do
    login_as chris
    get :show, :id => simple_task.id
    submit_form 'favorite_task' 
  end

  specify "adds that task to the list of favorites" do
    chris.favorites.should.include simple_task
  end

  specify "redirects back to the task" do
    should.redirect_to task_path(simple_task)
  end
end

context "Unfavoriting a task" do
  scenario :default
  use_controller TasksController

  setup do
    chris.favorite(simple_task)
    assert chris.favorites.include?(simple_task)

    login_as chris
    get :show, :id => simple_task.id
    submit_form 'favorite_task' 
  end

  specify "removes that task to the list of favorites again" do
    chris.favorites.should.not.include simple_task
  end

  specify "redirects back to the task" do
    should.redirect_to task_path(simple_task)
  end
end

context "Favoriting a task when logged in (js)" do
  scenario :default
  use_controller TasksController

  setup do
    login_as chris
    get :show, :id => simple_task.id
    submit_form 'favorite_task', :xhr => true
  end

  specify "adds that task to the list of favorites" do
    chris.favorites.should.include simple_task
  end

  specify "returns a success code" do
    assert_response :success
  end
end

context "Favoriting a task when not logged in" do
  scenario :default
  use_controller TasksController

  setup do
    login_as :anonymous
    post :favorite, :id => simple_task.id
  end

  specify "redirects back to the task" do
    should.redirect_to task_path(simple_task)
  end
end

context "Favoriting a task when not logged in (js)" do
  scenario :default
  use_controller TasksController

  setup do
    login_as :anonymous
    post :favorite, :id => simple_task.id, :format => 'js'
  end

  specify "returns an error code" do
    assert_response 401
  end
end

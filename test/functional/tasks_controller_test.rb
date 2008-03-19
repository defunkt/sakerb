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

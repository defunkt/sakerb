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

require File.dirname(__FILE__) + '/../test_helper'

context "FavoritesController" do
  scenario :default
  use_controller FavoritesController

  setup do
    login_as chris
    chris.favorite simple_task
    get :index, :user_id => chris.id
  end

  specify "lists a user's favorites" do
    body['.tasks'].should.include simple_task.name
  end
end

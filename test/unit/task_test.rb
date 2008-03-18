require File.dirname(__FILE__) + '/../test_helper'

context "A user's task" do
  scenario :default

  setup do
    @task = tasks(:simple_task)
  end

  specify "knows its owner" do
    assert_equal chris, @task.user
  end

  specify "knows its view count" do
    assert_equal 0, @task.views
  end

  specify "knows its version" do
    assert_equal 1, @task.version
  end

  specify "knows whether it is approved" do
    assert @task.not.approved?
  end

  specify "can add a view" do
    assert_difference '@task.reload.views' do
      @task.add_view
    end
  end
end

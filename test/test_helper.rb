ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

require 'test/spec/rails'

begin; require 'redgreen'; rescue LoadError; end

class Test::Unit::TestCase
  include BodyMatcher

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  def chris
    @chris_fixture ||= users(:chris)
  end

  def bob
    @bob_fixture ||= users(:bob)
  end

  def simple_task
    @simple_task_fixture ||= tasks(:simple_task)
  end

  def assert_content_type(expected)
    assert_equal "#{expected}; charset=utf-8", @response.headers['type']
  end

  def login_as(user)
    return fake_anonymous_user if user == :anonymous

    user = if user.is_a?(User) 
      user 
    elsif user.to_s.to_i.zero?
      User.find_by_login(user.to_s.titleize)
    else
      User.find(user)
    end

    @controller.stubs(:logged_in?).returns(true)
    @controller.stubs(:current_user).returns(user)

    user
  end


  def fake_anonymous_user
    @controller.stubs(:logged_in?).returns(false)
    @controller.stubs(:current_user).returns(nil)
  end
end

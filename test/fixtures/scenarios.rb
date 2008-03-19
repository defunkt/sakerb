scenario :default do
  chris = User.create! \
    :login => 'chris',
    :email => 'chris@ozmm.org',
    :password => 'password',
    :password_confirmation => 'password'

  
  chris.tasks.create! \
    :body => '# a sake task',
    :description => 'simple',
    :name => 'simple_task'

  Dir[File.dirname(__FILE__) + '/tasks/*.task'].each do |task|
    chris.tasks.create! \
      :body => File.read(task),
      :description => 'a task',
      :name => File.basename(task, '*.task')

  end

  bob = User.create! \
    :login => 'bob',
    :email => 'bob@ozmm.org',
    :password => 'password',
    :password_confirmation => 'password'
end

class << ActiveRecord::Base
  def skip_stamps
    self.record_timestamps = false
    yield
    self.record_timestamps = true
  end
end

scenario :authentication do
  users = %w( quentin aaron )
  created_at = [ 5.days.ago, 1.day.ago ]

  ActiveRecord::Base.skip_stamps do
    users.each do |user|
      user = User.new :login => user, :email => "#{user}@example.com"
      user.salt = '7e3041ebc2fc05a40c60028e2c4901a81035d3cd'
      user.created_at = created_at.shift
      user.crypted_password = '00742970dc9e6319f8019fd54864d3ea740f04b1'
      user.save
    end
  end
end

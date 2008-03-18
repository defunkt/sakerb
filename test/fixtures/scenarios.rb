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
end

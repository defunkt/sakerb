namespace :db do
  desc 'Bootstrap the dev db'
  task :bootstrap => %w( db:drop db:create db:migrate db:scenario:build ) do
    ENV.update('SCENARIO' => 'default')
    Rake::Task['db:scenario:load'].invoke
  end
end

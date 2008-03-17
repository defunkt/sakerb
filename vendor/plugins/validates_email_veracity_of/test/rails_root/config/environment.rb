require File.join(File.dirname(__FILE__), 'boot')
 
Rails::Initializer.run do |config|
  config.log_level = :debug
  config.cache_classes = false
  config.whiny_nils = true
  config.breakpoint_server = true
  config.load_paths << "#{File.dirname(__FILE__)}/../../../lib/"
end
 
Dependencies.log_activity = true

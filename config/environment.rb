require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.frameworks -= [ :active_resource, :action_mailer ]

  config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
    File.directory?(lib = "#{dir}/lib") ? lib : dir
  end

  config.load_paths += Dir["#{RAILS_ROOT}/app/models/**"]

  config.action_controller.session = {
    :session_key => '_sakerb_session',
    :secret      => '1b28e05a88d8c50da86fcd016b533aff4d0ba4daf40f5af2c79b204d8b9588cc7bb199d291784c1edab0f5e0b819fccaa3a43a829e7f6508b20bb45399bcbd07'
  }

  config.active_record.default_timezone = :utc
end

#begin
#  Bj.config["production.no_tickle"] = true 
#rescue Object
#  nil
#end

config.cache_classes = true
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true
config.action_mailer.raise_delivery_errors           = false
# config.action_controller.asset_host                  = "http://assets.example.com"

ENV['RAILS_ASSET_ID'] = File.read(RAILS_ROOT + '/.git/refs/heads/deploy').chomp

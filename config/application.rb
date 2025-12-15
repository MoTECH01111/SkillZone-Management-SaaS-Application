require_relative "boot"

require "rails/all"
Bundler.require(*Rails.groups)

module SkillzoneApi
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])
    config.api_only = true

    # Allows PDF to load from localhost:5000
    config.action_dispatch.default_headers.merge!({
      "X-Frame-Options" => "ALLOWALL",
      "Access-Control-Allow-Origin" => "*"
    })
  end
end

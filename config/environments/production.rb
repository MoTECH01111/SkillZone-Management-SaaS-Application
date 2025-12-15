require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings.
  config.eager_load = true

  # Disable full error reports.
  config.consider_all_requests_local = false

  # Serve static files if Render enables it
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.year.to_i}"
  }

  # Store uploaded files locally (OK for now)
  config.active_storage.service = :local

  # SSL settings Render terminates SSL
  config.assume_ssl = true
  config.force_ssl = true

  # Logging
  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Silence health check logs
  config.silence_healthcheck_path = "/up"

  # Disable deprecation warnings
  config.active_support.report_deprecations = false

  # Cache (simple + safe)
  config.cache_store = :memory_store

  # Background jobs (NO solid_queue)
  config.active_job.queue_adapter = :async

  # Mailer (safe defaults)
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST", "localhost")
  }

  # I18n
  config.i18n.fallbacks = true

  # Database
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]
end

source "https://rubygems.org"

# Rails framework
gem "rails", "~> 8.0.4"

# PostgreSQL
gem "pg", "~> 1.1"

# Puma web server
gem "puma", ">= 5.0"

# Timezone data for Windows / JRuby
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Faster boot times
gem "bootsnap", require: false

# Deploy via containers
gem "kamal", require: false

# Puma acceleration / HTTP optimizations
gem "thruster", require: false


# Enable Cross-Origin Resource Sharing Flask
gem "rack-cors"
# DEVELOPMENT & TEST
group :development, :test do
  # Debugging tools
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Security scanner
  gem "brakeman", require: false

  # Ruby/Rails style enforcement
  gem "rubocop-rails-omakase", require: false
end
# TEST ONLY
group :test do
  gem "mocha", require: false
end

# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module YamfrpgApi
  # Rails application for API.
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    [
      "#{config.root}/app/controllers",
      "#{config.root}/app/jobs",
      "#{config.root}/app/mailers",
      "#{config.root}/app/models",
      "#{config.root}/app/serializers"
    ].each do |path|
      if path.is_a?(String)
        config.autoload_paths << path
        config.eager_load_paths << path
      else
        config.autoload_paths += path
        config.eager_load_paths += path
      end
    end

    config.generators.test_framework :rspec
    config.middleware.use ActionDispatch::Flash

    config.i18n.enforce_available_locales = true
    config.i18n.available_locales = %i[en-CA en-US en es]
    config.i18n.available_locales.each do |locale|
      config.send("#{locale.to_s.tr('-', '_')}?=", locale == config.i18n.default_locale)
    end

    config.allow_concurrency = true

    config.factory_bot.reject_primary_key_attributes = false if Rails.env.test?

    config.session_store :cookie_store, key: '_interslice_session'
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options

    config.after_initialize do
      Rails.application.routes.default_url_options = config.action_mailer.default_url_options
    end
  end
end

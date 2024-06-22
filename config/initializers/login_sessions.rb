# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  LoginSessions.configure do |config|
    config.header_names = {
      user: {
        email: 'X-User-Email',
        authentication_token: 'X-User-Authentication-Token',
        authentication_uuid: 'X-User-Authentication-Uuid'
      }
    }
    config.identifiers = { user: 'email' }
  end
end

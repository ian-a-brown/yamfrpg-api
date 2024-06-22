# frozen_string_literal: true

Rails.application.config.to_prepare do
  ActiveModelSerializers.config.default_includes = '**'
end

# frozen_string_literal: true

module Yamfrpg
  module Engine
    module LoginSessions
      # Serializer for login session credentials.
      class LoginSessionCredentialsSerializer < ActiveModel::Serializer
        attributes :success,
                   :user_id,
                   :email,
                   :expires,
                   :token,
                   :uuid

        def email
          object&.user&.email
        end

        def expires
          object&.expires&.utc
        end

        def success
          true
        end
      end
    end
  end
end

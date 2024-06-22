# frozen_string_literal: true

module Yamfrpg
  module Engine
    module Users
      # Devise sessions controller for the YAMFRPG API.
      class SessionsController < Devise::SessionsController
        include JsonResponder
        include LoadSerializer

        acts_as_token_uuid_authentication_handler_for Yamfrpg::Engine::User, only: :destroy

        before_action :ensure_login_params_exist!, only: :create

        def create
          user = find_user
          return unless user.present? && check_login_session?(user)

          complete_sign_in!(user)
        end

        # rubocop: disable Metrics/MethodLength
        def destroy
          token_was_removed = remove_current_user_token!
          sign_out(resource_name)
          respond_json({ success: true }) and return if token_was_removed

          respond_json({
                         success: false,
                         message: 'Invalid token or some internal server user while saving'
                       },
                       :unauthorized)
        rescue LoginSessions::ExpiredTokenError
          Rails.logger.warn("Signout for #{current_user.email} without login session or with expired login session")
          respond_json({ success: false, message: 'No login session or login session has expired' })
        end
        # rubocop: enable Metrics/MethodLength

        protected

        def find_user
          user = Yamfrpg::Engine::User.find_for_database_authentication(email: login_params[:email])
          unless user.present? && user.valid_password?(login_params[:password])
            invalid_login_attempt!('Error with your email address or password')
            return
          end

          user
        end

        def check_login_session?(user)
          login_session = Yamfrpg::Engine::LoginSession.find_by(user:, uuid: login_params[:uuid])
          invalid_login_attempt!('You are already logged in') and return false if login_session.present?

          true
        end

        def ensure_login_params_exist!
          return if params[:user_login].present?

          invalid_login_attempt!('Missing user login parameter', :unprocessable_entity)
        end

        def invalid_login_attempt!(message, status = :unauthorized)
          Rails.logger.warn("Invalid login attempt: #{message}")
          warden.custom_failure!
          respond_json({ success: false, message: }, status)
        end

        def login_params
          params.require(:user_login).permit(:email, :password, :uuid)
        end

        def verify_signed_out_user; end

        private

        def complete_sign_in!(user)
          sign_in(user.class.name, user)
          login_session = create_login_session!(user)

          respond_json(login_session, :ok, load_serializer(login_session.class, 'Credentials'))
        end

        def create_login_session!(user)
          token = user.authentication_token
          user.update!(authentication_token: nil)
          LoginSession.create!(user:, token:, uuid: login_params[:uuid], expires: 2.hours.from_now)
        end

        def remove_current_user_token!
          return true unless current_user.present?

          Yamfrpg::Engine::LoginSession.find_by(user: current_user)&.destroy!
          current_user.update_attribute(:authentication_token, nil)
          true
        end
      end
    end
  end
end

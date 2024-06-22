# frozen_string_literal: true

# Base controller for the applications in YAMFRPG.
class ApplicationController < ActionController::Base
  include JsonResponder

  before_action :configure_permitted_parameters, if: :devise_controller?
  skip_before_action :verify_authenticity_token

  serialization_scope :view_context

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update) do |user|
      user.permit(:reset_password_token, :password, :password_confirmation)
    end
  end
end

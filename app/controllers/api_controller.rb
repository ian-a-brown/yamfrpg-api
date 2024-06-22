# frozen_string_literal: true

# Base controller for the API in YAMFRPG.
class ApiController < ActionController::API
  include JsonResponder
  include LoadSerializer
  include Pundit::Authorization

  acts_as_token_uuid_authentication_handler_for Yamfrpg::Engine::User

  before_action :authenticate_user!, fallback: :exception
  before_action :set_user_time_zone!

  after_action :verify_pundit

  serialization_scope :current_user_scope

  def collection_methods
    ['index']
  end

  def current_user_scope
    my_user = current_user

    proxy_class = Class.new do
      @current_user = my_user

      attr_reader :current_user
    end

    proxy_class.new
  end

  def each_serializer
    nil
  end

  def no_verify_methods
    []
  end

  def serializer
    nil
  end

  def verify_pundit
    return if no_verify_methods.include?(action_name)
    verify_authorized and return unless collection_methods.include?(action_name)

    verify_policy_scoped
  end

  protected

  def check_update_protected_field(field, editable_fields, _model)
    return unless field_is_protected?(field, editable_fields)

    model.errors.add(field, 'not authorized to change')
  end

  def check_update_protected_fields(fields, editable_fields, model)
    return true if params[:force] && current_user.administrator?

    fields.each { |field| check_update_protected_field(field, editable_fields, model) }
    check_for_update_protected_fields_error(model)
  end

  def field_is_protected?(field, editable_fields)
    return hash_field_is_protected?(field, editable_fields) if field.is_a?(Hash)

    !editable_fields.include?(field)
  end

  def hash_field_is_protected?(_hash, editable_fields)
    editable_fields.find do |editable_field|
      return true unless editable_field.is_a?(Hash)

      editable_field.keys? == field.keys?
    end.present?
  end
end

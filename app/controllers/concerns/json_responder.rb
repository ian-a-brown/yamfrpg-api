# frozen_string_literal: true

# Provides methods to respond using JSON. Includes handlers for rescuing errors as well as methods for regular
# responses.
module JsonResponder
  extend ActiveSupport::Concern

  # rubocop: disable Metrics/BlockLength
  included do
    rescue_from ActiveRecord::InvalidForeignKey do |e|
      status = if /is not present/ =~ e.message
                 :not_found
               else
                 :unprocessable_entity
               end

      respond_rescue_json(e, status)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      respond_rescue_json(e, :not_found)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      respond_rescue_json(e, :not_found)
    end

    rescue_from ArgumentError do |e|
      if /is not valid/ =~ e.message
        respond_rescue_json(e, :unprocessable_entity, e.message.slice(/is not valid (.*)/, 1))
        return
      end

      respond_rescue_json(e)
    end

    rescue_from Pundit::NotAuthorizedError do |e|
      respond_rescue_json(e, :forbidden)
    end

    rescue_from StandardError do |e|
      respond_rescue_json(e, :unprocessable_entity)
    end

    def respond_failed_validation(errors, status = :unprocessable_entity)
      logger.error(errors.full_messages_to_sentence)
      Thread.current.backtrace { |line| logger.error(line) }
      respond_json(errors, status)
    end

    # rubocop: disable Metrics/MethodLength
    def respond_json(object, status = :ok, override_serializer = nil)
      response.headers['Access-Control-Allow-Origin'] = '*' unless Rails.env.development?

      case object
      when Array
        respond_array_json(object, status, override_serializer)
      when ActiveRecord::Relation
        respond_array_json(object.to_a, status, override_serializer)
      when ActiveRecord::Base
        respond_active_record_json(object, status, override_serializer)
      else
        respond_object_json(object, status, override_serializer)
      end
    end
    # rubocop: enable Metrics/MethodLength
  end
  # rubocop: enable Metrics/BlockLength

  private

  def respond_active_record_json(object, status, override_serializer)
    if override_serializer.present?
      render(json: object, status:, serializer: override_serializer)
      return
    end

    if respond_to?(:serializer) && serializer.present?
      render(json: object, status:, serializer:)
      return
    end

    render(json: object, status:)
  end

  def respond_array_json(array, status, override_serializer)
    if override_serializer
      render(json: array, status:, override_serializer:)
      return
    end

    if respond_to?(:each_serializer) && each_serializer.present?
      render(json: array, status:, serializer: each_serializer)
      return
    end

    render(json: array, status:)
  end

  def respond_object_json(object, status, override_serializer)
    if override_serializer
      render(json: object, status:, serializer: override_serializer)
      return
    end

    render(json: object, status:)
  end

  def respond_rescue_json(error, status = :unprocessable_entity, _field = 'message')
    logger.error("#{error.class.name} #{error.message}")
    error.backtrace.each { |line| logger.error(line) }
    render(status:, json: { message: error.message })
  end
end

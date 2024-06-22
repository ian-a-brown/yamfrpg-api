# frozen_string_literal: true

# RSpec helper module for testing requests.
module RequestSpecHelper
  include Warden::Test::Helpers

  def self.included(base)
    base.before(:each) { Warden.test_mode! }
    base.after(:each) { Warden.test_reset! }
  end

  def copy_json_fields_to_model(json, model, fields)
    return unless json.present? && model.present? && fields.present?

    fields.each do |field|
      model.send("#{field}=", json[field.to_s])
    end
  end

  def copy_json_fields_to_models(json, models, fields)
    return unless json.present? && models.present? && fields.present?

    json.each_with_index do |entry, idx|
      copy_json_fields_to_model(entry, models[idx], fields)
    end
  end

  def full_example_args(model, additional_params)
    return [model_id(model, additional_params)] unless additional_params[:request_args]

    request_args
  end

  def json
    json_from(response)
  end

  def json_from(object)
    JSON.parse(object.body) unless object.body.empty?
  end

  def model_id(model, additional_params)
    return model.id unless additional_params.key?(:id_field)

    model.send(additional_params[:id_field])
  end

  def sign_in(resource)
    login_as(resource, scope: warden_scope(resource))
  end

  def sign_out(resource)
    logout(warden_scope(resource))
  end

  private

  def warden_scope(resource)
    Devise::Mapping.find_scope!(resource)
  end
end

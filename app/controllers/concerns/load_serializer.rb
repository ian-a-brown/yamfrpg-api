# frozen_string_literal: true

# Concern to load YAMFRPG serializers by class and serializer type.
module LoadSerializer
  extend ActiveSupport::Concern

  included do
    def load_serializer(klass, serializer_type = nil)
      return load_type_serializer(klass, serializer_type) if serializer_type.present?

      load_base_serializer(klass)
    end

    def plural_class(klass)
      singular = klass.name
      pluralize(singular)
    end
  end

  private

  def load_base_serializer(klass)
    "#{klass.name}Serializer".constantize
  end

  def load_type_serializer(klass, serializer_type)
    plural_klass_name = plural_class(klass)
    "#{plural_klass_name}::#{klass.name.demodulize}#{serializer_type}Serializer".constantize
  end

  def pluralize(singular)
    return pluralize_with_of(singular) if singular =~ /[a-z]Of[A-Z]/
    return pluralize_with_y(singular) if singular.end_with?('y')
    return "#{singular}s" unless singular.end_with?('s') || singular.end_with?('x')

    "#{singular}es"
  end

  def pluralize_with_of(singular)
    idx = singular.index(/[a-z]Of[A-Z]/)
    "#{pluralize(singular[0..idx])}Of#{singular[(idx + 4)..]}"
  end

  def pluralize_with_y(singular)
    "#{singular[0..-2]}ies"
  end
end

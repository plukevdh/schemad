require 'schemad/extensions'

module Schemad
  class Normalizer
    include Schemad::Extensions

    def self.inherited(subclass)
      subclass.instance_variable_set(:@normalizers, {})
    end

    def self.filter_attributes_with(entity)
      @allowed_attributes = entity.attribute_names
    end

    def self.normalize(name, args={}, &block)
      lookup = args[:key] || name
      method_name = normalizer_method_name(name)

      @normalizers[lookup] = name

      define_method method_name do |data|
        value = data[lookup]
        return value unless block_given?

        yield value
      end
    end

    def normalize(data)
      normalized = {}

      data.each do |key, value|
        to_key = normalizers[key]
        next unless allowed_attribute?(to_key)

        if to_key
          normalized[to_key] = self.send normalizer_method_name(to_key), data
        else
          normalized[key.to_sym] = value
        end
      end

      normalized
    end

    def normalizers
      self.class.instance_variable_get(:@normalizers)
    end

    def allowed_attributes
      self.class.instance_variable_get(:@allowed_attributes)
    end

    private
    def allowed_attribute?(attr)
      allowed_attributes.nil? || allowed_attributes.include?(attr)
    end

    def self.normalizer_method_name(field)
      "normalize_#{field}".to_sym
    end

    def normalizer_method_name(field)
      self.class.normalizer_method_name(field)
    end
  end
end
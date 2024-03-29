require 'schemad/extensions'

module Schemad
  module Normalizer
    extend ActiveSupport::Concern
    include Schemad::Extensions

    DELIMITER = "/"

    InvalidPath = Class.new(StandardError)

    included do
      instance_variable_set(:@normalizers, {})
      instance_variable_set(:@allowed_attributes, [])
    end

    module ClassMethods
      def inherited(subclass)
        default_normalizers = inherited_var(:@normalizers, {})
        subclass.instance_variable_set(:@normalizers, default_normalizers)

        default_allowed = inherited_var(:@allowed_attributes, [])
        subclass.instance_variable_set(:@allowed_attributes, default_allowed)
      end

      def include_fields(*fields)
        @allowed_attributes.concat fields
      end

      def normalize(name, args={}, &block)
        lookup = args[:key] || name
        method_name = normalizer_method_name(name)

        @normalizers[lookup] = name
        @allowed_attributes << lookup

        define_method method_name do |data|
          value = find_value lookup, data
          return value unless block_given?

          yield value
        end
      end

      def normalizer_method_name(field)
        "normalize_#{field}".to_sym
      end

    end

    def normalize(data)
      normalized = {}

      allowed_attributes.each do |key|
        to_key = normalizers[key]

        if to_key
          normalized[to_key] = self.send normalizer_method_name(to_key), data
        else
          normalized[key_from_path(key)] = find_value(key, data)
        end
      end

      normalized
    end

    def reverse(data)
      normalized = {}

      allowed_attributes.each do |key|
        from_key = normalizers[key] || key

        normalized.deep_merge! nested_hash_from_path(key, data[from_key])
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

    def path_steps(key)
      key.to_s.split(DELIMITER)
    end

    def key_from_path(path)
      path_steps(path).last.to_sym
    end

    def find_value(key, data)
      begin
        search_data path_steps(key), indifferent_hash(data)
      rescue InvalidPath => e
        # rethrow with more info
        raise e, "Can't find value for \"#{key}\""
      end
    end

    def nested_hash_from_path(path, value)
      build_hash path_steps(path), value, {}
    end

    def build_hash(steps, value, accum)
      step = steps.shift
      accum[step] = steps.empty? ? value : build_hash(steps, value, {})
      accum
    end

    def search_data(steps, data)
      step = steps.shift
      return data unless step
      raise InvalidPath if data.nil?

      search_data steps, data[step]
    end

    def normalizer_method_name(field)
      self.class.normalizer_method_name(field)
    end
  end
end

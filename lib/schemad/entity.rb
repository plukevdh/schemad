require 'schemad/extensions'
require 'schemad/type_handler'

module Schemad
  module Entity
    extend ActiveSupport::Concern
    include Schemad::Extensions

    included do
      instance_variable_set(:@attributes, [])
    end

    module ClassMethods
      def inherited(subclass)
        puts "INHERITED BY #{subclass}"
        default_attrs = inherited_var(:@attributes, [])
        subclass.instance_variable_set(:@attributes, default_attrs)
      end

      def attribute(name, args={}, &block)
        attr_accessor name

        define_parser_for(name, args, &block)
        @attributes << name
      end

      # expect data hash to have symbol keys at this point
      # normalizer should standardize this
      def from_data(data)
        obj = new

        @attributes.each do |key|
          value = obj.send "parse_#{key}", data
          obj.send "#{key}=", value
        end

        obj
      end

      def attribute_names
        @attributes
      end

      private

      def define_parser_for(name, args, &block)
        define_method "parse_#{name}" do |data|
          value = data[name]
          value ||= get_default(args[:default])

          self.send "#{name}=", coerce_to_type(value, args[:type])
        end

        define_method "#{name}?" do
          !!send(name)
        end if args[:type] == :boolean
      end
    end

    def attribute_names
      self.class.attribute_names
    end

    def to_hash
      hash = {}
      attribute_names.each do |key|
        hash[key] = send key
      end

      hash
    end

    alias_method :attributes, :to_hash

    private

    def get_default(default_provider)
      return default_provider unless default_provider.is_a? Proc
      default_provider.call
    end

    def coerce_to_type(value, type)
      type ||= :string

      handler = TypeHandler.new type
      handler.parse(value)
    end
  end
end

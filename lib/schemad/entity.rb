require 'schemad/extensions'
require 'schemad/type_handler'

module Schemad
  class Entity
    extend Schemad::Extensions

    def self.inherited(subclass)
      subclass.instance_variable_set(:@attributes, [])
    end

    def self.attribute(name, args={}, &block)
      attr_accessor name

      define_parser_for(name, args, &block)

      @attributes << name
    end

    # expect data hash to have symbol keys at this point
    # normalizer should standardize this
    def self.from_data(data)
      obj = new

      @attributes.each do |key|
        value = obj.send "parse_#{key}", data
        obj.send "#{key}=", value
      end

      obj
    end

    def attribute_names
      self.class.instance_variable_get(:@attributes)
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

    def self.define_parser_for(name, args, &block)
      define_method "parse_#{name}" do |data|
        value = data[name]
        value ||= get_default(args[:default])

        self.send "#{name}=", coerce_to_type(value, args[:type])
      end

      define_method "#{name}?" do
        !!send(name)
      end if args[:type] == :boolean
    end

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

require 'schemad/extensions'
require 'schemad/type_handler'

module Schemad
  class Entity
    extend Schemad::Extensions

    def self.inherited(subclass)
      subclass.instance_variable_set(:@attributes, [])
    end

    def self.attribute(name, args, &block)
      attr_accessor name

      define_parser_for(name, args, &block)

      @attributes << name
    end

    def self.from_data(data)
      obj = new
      indiff = indifferent_hash(data)

      @attributes.each do |key|
        value = obj.send "parse_#{key}", indiff
        obj.send "#{key}=", value
      end

      obj
    end

    def attributes
      self.class.instance_variable_get(:@attributes)
    end

    # def to_hash
    #   hash = {}
    #   schema.keys.each do |key|
    #     hash[key] = send key
    #   end

    #   hash.each do |k,v|
    #     next unless v.is_a? Time
    #     hash[k] = v.utc.to_i
    #   end

    #   hash
    # end
    # alias_method :attributes, :to_hash

    private

    def self.define_parser_for(name, args, &block)
      lookup = args[:key] || name

      define_method "parse_#{name}" do |data|
        value = data[lookup]
        value ||= get_default(args[:default])

        value = block.call(value) if block_given? && !value.nil?

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
      handler = TypeHandler.new type
      handler.parse(value)
    end
  end
end

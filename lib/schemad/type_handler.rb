require 'time'
require 'schemad/extensions'

module Schemad
  class BooleanHandler
    VALID_TRUTHS = ["true", true, "t", "T", "1", 1, "TRUE"]
    def parse(value)
      VALID_TRUTHS.include? value
    end
  end

  class StringHandler
    def parse(value)
      value.to_s
    end
  end

  class IntegerHandler
    def parse(value)
      case value
      when TrueClass, FalseClass
        value ? 1 : 0
      else
        value.to_i rescue nil
      end
    end
  end

  class TimeHandler
    def parse(value)
      return value.to_time if value.respond_to?(:to_time)

      begin
        Time.at(value)
      rescue TypeError => e
        Time.parse(value)
      rescue ArgumentError => e
        nil
      end
    end
  end

  TYPES = {
    string: StringHandler,
    boolean: BooleanHandler,
    integer: IntegerHandler,
    datetime: TimeHandler,
    time: TimeHandler,
    date: TimeHandler
  }

  class TypeHandler
    include Extensions
    extend Forwardable
    UnknownDataType = Class.new(Exception)

    def initialize(type)
      handler = TYPES[type]

      raise UnknownDataType, "No known handlers for #{classify(type)}" if handler.nil?

      @handler = handler.new
    end

    def_delegators :@handler, :parse
  end
end
module Schemad
	class IntegerHandler < AbstractHandler
    handle :integer

    def parse(value)
      case value
      when TrueClass, FalseClass
        value ? 1 : 0
      else
        value.to_i rescue nil
      end
    end
  end
end

Schemad::IntegerHandler.register_with Schemad::TypeHandler
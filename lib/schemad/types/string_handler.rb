module Schemad
	class StringHandler < AbstractHandler
    handle :string

    def parse(value)
      value.to_s
    end
  end
end

Schemad::StringHandler.register_with Schemad::TypeHandler
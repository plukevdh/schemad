module Schemad
  class BooleanHandler < AbstractHandler
    VALID_TRUTHS = ["true", true, "t", "T", "1", 1, "TRUE"]

    handle :boolean, :bool

    def parse(value)
      VALID_TRUTHS.include? value
    end
  end
end

Schemad::BooleanHandler.register_with Schemad::TypeHandler
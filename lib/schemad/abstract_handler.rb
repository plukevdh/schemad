module Schemad
	class AbstractHandler
		def self.register_with(with)
			with.register self
		end

    def self.handle(*types)
      @types ||= []
      @types.concat types
    end

    def self.handles
      @types
    end
	end
end
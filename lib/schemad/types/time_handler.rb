module Schemad
  class TimeHandler < AbstractHandler
    handle :time, :date, :date_time

    def parse(value)
      return nil if value.nil?  # bail on nil
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
end

Schemad::TimeHandler.register_with Schemad::TypeHandler

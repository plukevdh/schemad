module Schemad
  class TimeHandler < AbstractHandler
    handle :time, :date, :date_time

    def parse(value)
      return nil if value.nil? || value.blank?
      return value.to_time if value.respond_to?(:to_time)

      Time.at(value)
    rescue TypeError => e
      Time.parse(value)
    end
  end
end

Schemad::TimeHandler.register_with Schemad::TypeHandler

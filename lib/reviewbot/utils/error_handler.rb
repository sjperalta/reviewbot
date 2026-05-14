module Reviewbot
  module Utils
    class ErrorHandler
      SEVERITY_MAP = {
        "CRITICAL" => :critical,
        "HIGH" => :high,
        "MEDIUM" => :medium,
        "LOW" => :low
      }.freeze

      class ToolNotFoundError < StandardError; end
      class NetworkError < StandardError; end
      class ConfigError < StandardError; end
      class APIError < StandardError; end

      def self.handle(error, context: "")
        case error
        when ToolNotFoundError
          Reviewbot::Utils::Logger.warn "[#{context}] Tool not found: #{error.message}"
          nil
        when NetworkError
          Reviewbot::Utils::Logger.error "[#{context}] Network error: #{error.message}"
          nil
        when ConfigError
          Reviewbot::Utils::Logger.error "[#{context}] Configuration error: #{error.message}"
          nil
        when APIError
          Reviewbot::Utils::Logger.error "[#{context}] API error: #{error.message}"
          nil
        else
          Reviewbot::Utils::Logger.error "[#{context}] Unexpected error: #{error.message}"
          nil
        end
      end

      def self.severity_from_string(str)
        SEVERITY_MAP.fetch(str, :low)
      end
    end
  end
end

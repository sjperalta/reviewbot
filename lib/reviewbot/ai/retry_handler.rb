module Reviewbot
  module AI
    class RetryHandler
      def initialize(max_retries: nil, delays: nil)
        @max_retries = max_retries || Config::Defaults::MAX_RETRIES
        @delays = delays || Config::Defaults::RETRY_DELAYS
      end

      def with_retry(&block)
        last_error = nil

        (@max_retries + 1).times do |attempt|
          begin
            return block.call(attempt)
          rescue Utils::ErrorHandler::NetworkError, Utils::ErrorHandler::APIError => e
            last_error = e
            if attempt < @max_retries
              delay = @delays[attempt] || @delays.last
              Reviewbot::Utils::Logger.warn "API attempt #{attempt + 1} failed: #{e.message}. Retrying in #{delay}s..."
              sleep(delay)
            end
          end
        end

        raise last_error if last_error
      end
    end
  end
end

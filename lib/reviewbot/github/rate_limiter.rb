module Reviewbot
  module GitHub
    class RateLimiter
      def initialize(client: nil)
        @client = client || Client.new
      end

      def check!
        remaining = @client.octokit.rate_limit.remaining
        if remaining < 10
          reset_time = @client.octokit.rate_limit.resets_at
          wait_seconds = [(reset_time - Time.now).ceil, 0].max
          Reviewbot::Utils::Logger.warn "GitHub API rate limit low (#{remaining} remaining). Resets in #{wait_seconds}s"
          if remaining == 0
            sleep(wait_seconds + 1)
          end
        end
        remaining
      rescue => e
        Reviewbot::Utils::Logger.warn "Rate limit check failed: #{e.message}"
        0
      end

      def remaining
        @client.octokit.rate_limit.remaining
      rescue
        0
      end
    end
  end
end

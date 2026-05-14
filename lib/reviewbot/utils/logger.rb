module Reviewbot
  module Utils
    class Logger
      LEVELS = {debug: 0, info: 1, warn: 2, error: 3}.freeze

      class << self
        def level
          @level ||= LEVELS.fetch(ENV.fetch("REVIEWBOT_LOG_LEVEL", "info").to_sym, 1)
        end

        def level=(lvl)
          @level = LEVELS.fetch(lvl, 1)
        end

        def debug(msg)
          return if level > 0
          $stderr.puts "[DEBUG] #{msg}"
        end

        def info(msg)
          return if level > 1
          $stderr.puts "[INFO] #{msg}"
        end

        def warn(msg)
          return if level > 2
          $stderr.puts "[WARN] #{msg}"
        end

        def error(msg)
          return if level > 3
          $stderr.puts "[ERROR] #{msg}"
        end
      end
    end
  end
end

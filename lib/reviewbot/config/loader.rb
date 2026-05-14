module Reviewbot
  module Config
    class Loader
      REQUIRED_VARS = %w[GITHUB_TOKEN].freeze
      OPTIONAL_VARS = %w[DEEPSEEK_API_KEY DEFAULT_BASE_BRANCH REVIEWBOT_WORKSPACE REVIEWBOT_OUTPUT_DIR REVIEWBOT_LOG_LEVEL].freeze

      def initialize
        @loaded = false
      end

      def load!
        load_env_file
        @loaded = true
        self
      end

      def get(key, default: nil)
        ENV.fetch(key, default)
      end

      def required?(key)
        REQUIRED_VARS.include?(key)
      end

      private

      def load_env_file
        paths = env_search_paths
        merged = {}
        paths.reverse_each do |path|
          next unless File.exist?(path)

          merged.merge!(Dotenv.parse(path, ignore: true))
          Reviewbot::Utils::Logger.debug "Merged .env from #{path}"
        end

        if merged.empty?
          Reviewbot::Utils::Logger.debug "No .env found in: #{paths.join(', ')}"
          return
        end

        Dotenv.update(merged, overwrite: false)
      end

      # Order: project cwd first in the array; {#load_env_file} merges in reverse so the cwd file wins on duplicate keys.
      def env_search_paths
        project_root = File.expand_path("../../..", __dir__)
        [
          File.join(Dir.pwd, ".env"),
          File.join(project_root, ".env"),
          File.expand_path("~/.reviewbot/.env")
        ]
      end

      public

      def validate!
        missing = REQUIRED_VARS.select { |var| ENV[var].nil? || ENV[var].empty? }
        unless missing.empty?
          raise Utils::ErrorHandler::ConfigError, "Missing required environment variables: #{missing.join(', ')}. See .env.example"
        end
        true
      end

      def deepseek_key_present?
        !ENV["DEEPSEEK_API_KEY"].nil? && !ENV["DEEPSEEK_API_KEY"].empty?
      end

      def base_branch
        ENV.fetch("DEFAULT_BASE_BRANCH", Defaults::BASE_BRANCH)
      end

      def workspace
        ENV.fetch("REVIEWBOT_WORKSPACE", Defaults::WORKSPACE_DIR)
      end

      def output_dir
        ENV.fetch("REVIEWBOT_OUTPUT_DIR", Defaults::OUTPUT_DIR)
      end
    end
  end
end

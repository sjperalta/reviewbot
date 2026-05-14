module Reviewbot
  module Config
    class RepositoryConfig
      attr_reader :stack, :rules, :ignore_patterns

      def initialize(path: nil)
        @path = path || find_config
        @data = load_config
        @stack = @data&.dig("stack") || []
        @rules = @data&.dig("rules") || {}
        @ignore_patterns = @data&.dig("ignore") || []
      end

      def exists?
        !@path.nil? && File.exist?(@path)
      end

      def stack_detected?
        !@stack.nil? && !@stack.empty?
      end

      def should_ignore?(file_path)
        return false if @ignore_patterns.empty?
        @ignore_patterns.any? do |pattern|
          File.fnmatch?(pattern, file_path, File::FNM_PATHNAME | File::FNM_DOTMATCH) ||
            File.fnmatch?(pattern, File.basename(file_path))
        end
      end

      private

      def find_config
        [".reviewbot.yml", ".reviewbot.yaml"].each do |f|
          return f if File.exist?(f)
        end
        nil
      end

      def load_config
        return nil unless @path && File.exist?(@path)
        Psych.safe_load_file(@path, permitted_classes: [Symbol])
      rescue Psych::SyntaxError => e
        Reviewbot::Utils::Logger.warn "Invalid .reviewbot.yml: #{e.message}"
        nil
      end
    end
  end
end

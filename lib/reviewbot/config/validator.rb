module Reviewbot
  module Config
    class Validator
      def initialize(loader: nil)
        @loader = loader || Loader.new
      end

      def validate!
        @loader.validate!
        true
      end

      def validate_soft
        errors = []
        unless ENV["GITHUB_TOKEN"] && !ENV["GITHUB_TOKEN"].empty?
          errors << "GITHUB_TOKEN is not set. Set it in .env (or ~/.reviewbot/.env) or export it; required for publish and other GitHub API use. Commands that only use gh may still work."
        end
        unless ENV["DEEPSEEK_API_KEY"] && !ENV["DEEPSEEK_API_KEY"].empty?
          errors << "DEEPSEEK_API_KEY is not set. AI review will be disabled. Set it in .env to enable."
        end
        errors
      end

      def self.check_required!
        new.validate!
      end
    end
  end
end

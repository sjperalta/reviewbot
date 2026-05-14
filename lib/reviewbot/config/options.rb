module Reviewbot
  module Config
    class Options
      attr_reader :base_branch, :output_dir, :workspace, :verbose, :config_path, :repo_config

      def initialize(cli_options: {}, loader: nil, repo_config: nil)
        @loader = loader || Loader.new
        @repo_config = repo_config

        @base_branch = cli_options.fetch(:base_branch, @loader.base_branch)
        @output_dir = cli_options.fetch(:output_dir, @loader.output_dir)
        @workspace = cli_options.fetch(:workspace, @loader.workspace)
        @verbose = cli_options.fetch(:verbose, false)
        @config_path = cli_options.fetch(:config_path, nil)
      end

      def stack
        @repo_config&.stack
      end

      def rules
        @repo_config&.rules || {}
      end

      def ignore_patterns
        @repo_config&.ignore_patterns || []
      end

      def ai_enabled?
        @loader.deepseek_key_present?
      end

      def to_h
        {
          base_branch: @base_branch,
          output_dir: @output_dir,
          workspace: @workspace,
          verbose: @verbose,
          config_path: @config_path,
          ai_enabled: ai_enabled?,
          stack: stack,
          rules: rules,
          ignore_patterns: ignore_patterns
        }
      end
    end
  end
end

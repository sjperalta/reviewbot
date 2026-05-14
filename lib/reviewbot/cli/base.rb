require "thor"

module Reviewbot
  module CLI
    class Base < Thor
      package_name "reviewbot"

      class_option :verbose, type: :boolean, default: false, desc: "Enable verbose output"
      class_option :config, type: :string, desc: "Path to configuration file"

      desc "prs", "List open PRs assigned to you for review"
      def prs
        Reviewbot::CLI::PRS.new.run
      end

      desc "review [PR_NUMBER]", "Review a pull request"
      option :all, type: :boolean, default: false, desc: "Review all assigned PRs"
      option :base_branch, type: :string, desc: "Override base branch"
      long_desc <<~LONGDESC
        `reviewbot review PR_NUMBER` reviews a specific pull request.

        `reviewbot review --all` reviews all open PRs assigned to you.

        If no PR_NUMBER or --all flag is provided, an interactive selector is shown.
      LONGDESC
      def review(pr_number = nil)
        Reviewbot::CLI::Review.new.run(pr_number: pr_number, options: options)
      end

      desc "publish PR_NUMBER", "Publish review findings to GitHub"
      def publish(pr_number)
        Reviewbot::CLI::Publish.new.run(pr_number)
      end

      desc "export PR_NUMBER", "Export review report as markdown"
      option :output_dir, type: :string, desc: "Output directory for report"
      def export(pr_number)
        Reviewbot::CLI::Export.new.run(pr_number, options)
      end

      desc "cache:clear", "Clear cached data"
      def cache_clear
        Reviewbot::CLI::Cache.new.clear
      end

      desc "version", "Print version"
      def version
        puts "reviewbot #{Reviewbot::VERSION}"
      end

      default_task :help
    end
  end
end

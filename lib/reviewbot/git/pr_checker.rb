module Reviewbot
  module Git
    class PRChecker
      def initialize(git_cli: nil)
        @git_cli = git_cli || CLI.new
      end

      def checkout(pr_number, repo_dir: nil)
        branch_name = "pr-#{pr_number}"
        Reviewbot::Utils::Logger.info "Checking out PR ##{pr_number}"

        result = @git_cli.execute("gh pr checkout #{pr_number}", dir: repo_dir)
        unless result
          raise Utils::ErrorHandler::ToolNotFoundError, "Failed to checkout PR ##{pr_number}. Is gh CLI installed?"
        end
        result
      end

      def checkout_and_fetch_sha(pr_number, repo_dir: nil)
        checkout(pr_number, repo_dir: repo_dir)
        @git_cli.current_sha(dir: repo_dir)
      end
    end
  end
end

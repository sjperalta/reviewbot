module Reviewbot
  module Git
    class BranchManager
      def initialize(git_cli: nil)
        @git_cli = git_cli || CLI.new
        @original_branch = nil
        @original_dir = nil
      end

      def save_current_branch(dir: nil)
        @original_dir = dir
        @original_branch = @git_cli.current_branch(dir: dir)
        Reviewbot::Utils::Logger.debug "Saved original branch: #{@original_branch}"
        @original_branch
      end

      def restore
        return unless @original_branch

        Reviewbot::Utils::Logger.info "Restoring branch: #{@original_branch}"
        @git_cli.checkout(@original_branch, dir: @original_dir)
        @original_branch = nil
      end

      def current_branch(dir: nil)
        @git_cli.current_branch(dir: dir)
      end
    end
  end
end

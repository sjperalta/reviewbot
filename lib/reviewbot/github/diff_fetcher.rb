module Reviewbot
  module GitHub
    class DiffFetcher
      def initialize(client: nil)
        @client = client || Client.new
      end

      def fetch_via_api(repo_full_name, pr_number)
        comparison = @client.compare(repo_full_name, "main", "refs/pull/#{pr_number}/head")
        parse_comparison(comparison)
      rescue => e
        Reviewbot::Utils::Logger.warn "Failed to fetch diff via API: #{e.message}"
        nil
      end

      def fetch_via_git(repo_path, base_branch, head_branch)
        git_cli = Reviewbot::Git::CLI.new
        output = git_cli.execute("git diff #{base_branch}...#{head_branch}", dir: repo_path)
        output || ""
      end

      private

      def parse_comparison(comparison)
        files = comparison[:files]&.map do |f|
          {
            path: f[:filename],
            status: f[:status],
            additions: f[:additions],
            deletions: f[:deletions],
            patch: f[:patch],
            contents_url: f[:contents_url]
          }
        end || []
        { files: files, total_commits: comparison[:total_commits], ahead_by: comparison[:ahead_by], behind_by: comparison[:behind_by] }
      end
    end
  end
end

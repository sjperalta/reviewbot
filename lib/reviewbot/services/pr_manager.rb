module Reviewbot
  module Services
    class PRManager
      def initialize(pr_selector: nil, repo_manager: nil, pr_checker: nil, branch_manager: nil, pr_lister: nil)
        @pr_selector = pr_selector || PRSelector.new(pr_lister: pr_lister || Reviewbot::GitHub::PRLister.new)
        @repo_manager = repo_manager || Reviewbot::Git::RepoManager.new
        @pr_checker = pr_checker || Reviewbot::Git::PRChecker.new
        @branch_manager = branch_manager || Reviewbot::Git::BranchManager.new
        @pr_lister = pr_lister || Reviewbot::GitHub::PRLister.new
      end

      def select_and_prepare(pr_number: nil)
        pr_data = if pr_number
                    @pr_selector.select_by_number(pr_number)
                  else
                    @pr_selector.select_interactive
                  end

        return nil unless pr_data

        prepare_pr(pr_data)
      end

      def prepare_all
        prs = @pr_lister.list_assigned
        prs.map { |pr_data| prepare_pr(pr_data) }.compact
      end

      def prepare_pr(pr_data)
        repo_full_name = repo_from_url(pr_data["url"])
        owner, name = repo_full_name.split("/")

        Reviewbot::Utils::Logger.info "Preparing PR ##{pr_data["number"]} from #{repo_full_name}"

        repo_path = @repo_manager.ensure_cloned(owner: owner, name: name)
        @branch_manager.save_current_branch(dir: repo_path)

        head_sha = @pr_checker.checkout_and_fetch_sha(pr_data["number"], repo_dir: repo_path)

        {
          number: pr_data["number"],
          title: pr_data["title"],
          author: pr_data["author"]&.dig("login"),
          repo_full_name: repo_full_name,
          repo_path: repo_path,
          head_sha: head_sha,
          base_branch: pr_data["baseRefName"] || "main",
          head_branch: pr_data["headRefName"]
        }
      end

      def cleanup
        @branch_manager.restore
      end

      private

      def repo_from_url(url)
        return "" unless url
        match = url.match(%r{https?://github\.com/([^/]+/[^/]+)})
        match ? match[1] : ""
      end
    end
  end
end

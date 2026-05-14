module Reviewbot
  module Services
    class PRSelector
      def initialize(pr_lister: nil)
        @pr_lister = pr_lister || Reviewbot::GitHub::PRLister.new
      end

      def select_interactive
        prs = @pr_lister.list_assigned
        if prs.empty?
          puts Pastel.new.yellow("No open PRs assigned to you for review.")
          return nil
        end

        prompt = TTY::Prompt.new
        choices = prs.map do |pr|
          repo = repo_from_url(pr["url"])
          { name: "##{pr["number"]} - #{pr["title"]} (#{repo})", value: pr }
        end

        prompt.select("Select a PR to review:", choices, per_page: 10)
      end

      def select_by_number(number)
        prs = @pr_lister.list_assigned
        wanted = Integer(number, exception: false)
        return nil if wanted.nil?

        prs.find { |pr| pr["number"].to_i == wanted }
      end

      def list_all
        @pr_lister.list_assigned
      end

      private

      def repo_from_url(url)
        return "unknown" unless url
        match = url.match(%r{https?://github\.com/([^/]+/[^/]+)})
        match ? match[1] : "unknown"
      end
    end
  end
end

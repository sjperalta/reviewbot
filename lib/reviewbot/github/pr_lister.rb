module Reviewbot
  module GitHub
    class PRLister
      def initialize
        @gh_cli = Reviewbot::Git::CLI.new
      end

      def list_assigned
        output = @gh_cli.execute("gh pr list --search \"review-requested:@me is:open\" --json number,title,author,url,headRefName,baseRefName,comments")
        return [] if output.nil? || output.empty?
        JSON.parse(output)
      rescue JSON::ParserError => e
        Reviewbot::Utils::Logger.error "Failed to parse PR list: #{e.message}"
        []
      end

      def list_for_repo(repo, state: "open")
        output = @gh_cli.execute("gh pr list --repo #{repo} --state #{state} --json number,title,author,url,headRefName,baseRefName")
        return [] if output.nil? || output.empty?
        JSON.parse(output)
      rescue JSON::ParserError => e
        Reviewbot::Utils::Logger.error "Failed to parse PR list for #{repo}: #{e.message}"
        []
      end
    end
  end
end

module Reviewbot
  module GitHub
    class PRFetcher
      def initialize(client: nil)
        @client = client || Client.new
      end

      def fetch(repo_full_name, pr_number)
        pr = @client.pull_request(repo_full_name, pr_number)
        files = @client.pull_request_files(repo_full_name, pr_number)
        commits = @client.pull_request_commits(repo_full_name, pr_number)
        labels = @client.pull_request_labels(repo_full_name, pr_number)

        parse_pr_data(pr, files, commits, labels)
      end

      def fetch_metadata(repo_full_name, pr_number)
        pr = @client.pull_request(repo_full_name, pr_number)
        labels = @client.pull_request_labels(repo_full_name, pr_number)

        {
          number: pr[:number],
          title: pr[:title],
          body: pr[:body],
          author: pr[:user][:login],
          state: pr[:state],
          labels: labels,
          base_branch: pr[:base][:ref],
          head_branch: pr[:head][:ref],
          head_sha: pr[:head][:sha],
          repo_full_name: pr[:base][:repo][:full_name],
          created_at: pr[:created_at],
          updated_at: pr[:updated_at]
        }
      end

      private

      def parse_pr_data(pr, files, commits, labels)
        {
          number: pr[:number],
          title: pr[:title],
          body: pr[:body],
          author: pr[:user][:login],
          state: pr[:state],
          labels: labels,
          base_branch: pr[:base][:ref],
          head_branch: pr[:head][:ref],
          head_sha: pr[:head][:sha],
          repo_full_name: pr[:base][:repo][:full_name],
          created_at: pr[:created_at],
          updated_at: pr[:updated_at],
          files: files.map { |f| parse_file(f) },
          commits: commits.map { |c| parse_commit(c) }
        }
      end

      def parse_file(file)
        {
          path: file[:filename],
          status: file[:status],
          additions: file[:additions],
          deletions: file[:deletions],
          patch: file[:patch]
        }
      end

      def parse_commit(commit)
        {
          sha: commit[:sha],
          message: commit[:commit][:message],
          author: commit[:commit][:author][:name],
          date: commit[:commit][:author][:date]
        }
      end
    end
  end
end

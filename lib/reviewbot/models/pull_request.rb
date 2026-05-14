module Reviewbot
  module Models
    class PullRequest
      attr_accessor :id, :repo_id, :number, :title, :author, :base_branch, :head_branch, :head_sha, :state, :created_at, :updated_at

      def initialize(id: nil, repo_id:, number:, title:, author:, base_branch:, head_branch:, head_sha:, state: "open", created_at: nil, updated_at: nil)
        @id = id
        @repo_id = repo_id
        @number = number
        @title = title
        @author = author
        @base_branch = base_branch
        @head_branch = head_branch
        @head_sha = head_sha
        @state = state
        @created_at = created_at
        @updated_at = updated_at
      end

      def to_hash
        {
          id: @id,
          repo_id: @repo_id,
          number: @number,
          title: @title,
          author: @author,
          base_branch: @base_branch,
          head_branch: @head_branch,
          head_sha: @head_sha,
          state: @state,
          created_at: @created_at,
          updated_at: @updated_at
        }
      end

      def self.from_row(row)
        new(
          id: row["id"],
          repo_id: row["repo_id"],
          number: row["number"],
          title: row["title"],
          author: row["author"],
          base_branch: row["base_branch"],
          head_branch: row["head_branch"],
          head_sha: row["head_sha"],
          state: row["state"],
          created_at: row["created_at"],
          updated_at: row["updated_at"]
        )
      end
    end
  end
end

module Reviewbot
  module Cache
    class PullRequest
      def initialize(db: nil)
        @db = db || Database.new.connect!
      end

      def find(id)
        row = @db.execute("SELECT * FROM pull_requests WHERE id = ?", [id]).first
        row ? Models::PullRequest.from_row(row) : nil
      end

      def find_by_repo_and_number(repo_id, number)
        row = @db.execute("SELECT * FROM pull_requests WHERE repo_id = ? AND number = ?", [repo_id, number]).first
        row ? Models::PullRequest.from_row(row) : nil
      end

      def find_or_create(repo_id:, number:, title:, author:, base_branch:, head_branch:, head_sha:)
        pr = find_by_repo_and_number(repo_id, number)
        return update_head_sha(pr.id, head_sha, title) if pr && pr.head_sha != head_sha
        return pr if pr

        @db.execute(
          "INSERT INTO pull_requests (repo_id, number, title, author, base_branch, head_branch, head_sha) VALUES (?, ?, ?, ?, ?, ?, ?)",
          [repo_id, number, title, author, base_branch, head_branch, head_sha]
        )
        find(@db.connection.last_insert_row_id)
      end

      def update_head_sha(id, head_sha, title = nil)
        if title
          @db.execute("UPDATE pull_requests SET head_sha = ?, title = ?, updated_at = datetime('now') WHERE id = ?", [head_sha, title, id])
        else
          @db.execute("UPDATE pull_requests SET head_sha = ?, updated_at = datetime('now') WHERE id = ?", [head_sha, id])
        end
        find(id)
      end

      def list_by_repo(repo_id, state: "open")
        @db.execute("SELECT * FROM pull_requests WHERE repo_id = ? AND state = ? ORDER BY number DESC", [repo_id, state])
          .map { |r| Models::PullRequest.from_row(r) }
      end
    end
  end
end

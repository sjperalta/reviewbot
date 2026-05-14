module Reviewbot
  module AI
    class ReviewCache
      def initialize(db: nil)
        @db = db || Reviewbot::Cache::Database.new.connect!
      end

      def get(pr_number, head_sha)
        row = @db.execute(
          "SELECT review_data, created_at FROM ai_review_cache WHERE pr_number = ? AND head_sha = ?",
          [pr_number, head_sha]
        ).first
        return nil unless row

        {
          data: JSON.parse(row["review_data"], symbolize_names: true),
          cached_at: row["created_at"]
        }
      rescue JSON::ParserError
        nil
      end

      def set(pr_number:, head_sha:, review_data:)
        data = review_data.is_a?(String) ? review_data : review_data.to_json
        @db.execute(
          "INSERT OR REPLACE INTO ai_review_cache (pr_number, head_sha, review_data) VALUES (?, ?, ?)",
          [pr_number, head_sha, data]
        )
      end

      def clear!
        @db.execute("DELETE FROM ai_review_cache")
      end

      def migrate!
        @db.execute(<<~SQL)
          CREATE TABLE IF NOT EXISTS ai_review_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pr_number INTEGER NOT NULL,
            head_sha TEXT NOT NULL,
            review_data TEXT NOT NULL,
            created_at TEXT DEFAULT (datetime('now')),
            UNIQUE(pr_number, head_sha)
          )
        SQL
      end
    end
  end
end

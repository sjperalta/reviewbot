module Reviewbot
  module Cache
    class DiffCache
      def initialize(db: nil)
        @db = db || Database.new.connect!
      end

      def get(pr_id, head_sha)
        row = @db.execute(
          "SELECT diff_data FROM cached_diffs WHERE pr_id = ? AND head_sha = ?",
          [pr_id, head_sha]
        ).first
        row ? JSON.parse(row["diff_data"]) : nil
      end

      def set(pr_id:, head_sha:, diff_data:)
        data = diff_data.is_a?(String) ? diff_data : diff_data.to_json
        @db.execute(
          "INSERT OR REPLACE INTO cached_diffs (pr_id, head_sha, diff_data) VALUES (?, ?, ?)",
          [pr_id, head_sha, data]
        )
      end

      def clear!
        @db.execute("DELETE FROM cached_diffs")
      end

      def clear_for_pr(pr_id)
        @db.execute("DELETE FROM cached_diffs WHERE pr_id = ?", [pr_id])
      end
    end
  end
end

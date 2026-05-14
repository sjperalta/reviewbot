module Reviewbot
  module Cache
    class ReviewRun
      def initialize(db: nil)
        @db = db || Database.new.connect!
      end

      def find(id)
        row = @db.execute("SELECT * FROM review_runs WHERE id = ?", [id]).first
        row ? Models::ReviewRun.from_row(row) : nil
      end

      def find_latest_by_pr(pr_id)
        row = @db.execute("SELECT * FROM review_runs WHERE pr_id = ? ORDER BY started_at DESC LIMIT 1", [pr_id]).first
        row ? Models::ReviewRun.from_row(row) : nil
      end

      def create(pr_id:, head_sha:, ai_model: nil)
        @db.execute(
          "INSERT INTO review_runs (pr_id, head_sha, ai_model) VALUES (?, ?, ?)",
          [pr_id, head_sha, ai_model]
        )
        find(@db.connection.last_insert_row_id)
      end

      def complete(id, risk_level:, finding_count:)
        @db.execute(
          "UPDATE review_runs SET status = 'completed', risk_level = ?, finding_count = ?, completed_at = datetime('now') WHERE id = ?",
          [risk_level, finding_count, id]
        )
      end

      def fail(id)
        @db.execute("UPDATE review_runs SET status = 'failed', completed_at = datetime('now') WHERE id = ?", [id])
      end

      def list_by_pr(pr_id)
        @db.execute("SELECT * FROM review_runs WHERE pr_id = ? ORDER BY started_at DESC", [pr_id])
          .map { |r| Models::ReviewRun.from_row(r) }
      end
    end
  end
end

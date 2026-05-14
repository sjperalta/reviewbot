module Reviewbot
  module Cache
    class Finding
      def initialize(db: nil)
        @db = db || Database.new.connect!
      end

      def find(id)
        row = @db.execute("SELECT * FROM findings WHERE id = ?", [id]).first
        row ? Models::Finding.from_row(row) : nil
      end

      def create(review_run_id:, severity:, category:, file_path:, line_number: nil, title:, description: nil, suggestion: nil, source: "ai")
        @db.execute(
          "INSERT INTO findings (review_run_id, severity, category, file_path, line_number, title, description, suggestion, source) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
          [review_run_id, severity, category, file_path, line_number, title, description, suggestion, source]
        )
        find(@db.connection.last_insert_row_id)
      end

      def list_by_review_run(review_run_id)
        @db.execute("SELECT * FROM findings WHERE review_run_id = ? ORDER BY severity DESC", [review_run_id])
          .map { |r| Models::Finding.from_row(r) }
      end

      def count_by_severity(review_run_id)
        rows = @db.execute(
          "SELECT severity, COUNT(*) as count FROM findings WHERE review_run_id = ? GROUP BY severity",
          [review_run_id]
        )
        rows.each_with_object({}) { |r, h| h[r["severity"]] = r["count"] }
      end
    end
  end
end

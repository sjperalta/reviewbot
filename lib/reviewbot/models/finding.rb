module Reviewbot
  module Models
    class Finding
      attr_accessor :id, :review_run_id, :severity, :category, :file_path, :line_number, :title, :description, :suggestion, :source

      SEVERITIES = %w[low medium high critical].freeze
      CATEGORIES = %w[security performance bug design test architecture style duplicate].freeze

      def initialize(id: nil, review_run_id:, severity: "medium", category: "bug", file_path:, line_number: nil, title:, description:, suggestion: nil, source: "ai")
        @id = id
        @review_run_id = review_run_id
        @severity = severity
        @category = category
        @file_path = file_path
        @line_number = line_number
        @title = title
        @description = description
        @suggestion = suggestion
        @source = source
      end

      def critical?
        @severity == "critical"
      end

      def high?
        @severity == "high"
      end

      def to_hash
        {
          id: @id,
          review_run_id: @review_run_id,
          severity: @severity,
          category: @category,
          file_path: @file_path,
          line_number: @line_number,
          title: @title,
          description: @description,
          suggestion: @suggestion,
          source: @source
        }
      end

      def self.from_row(row)
        new(
          id: row["id"],
          review_run_id: row["review_run_id"],
          severity: row["severity"],
          category: row["category"],
          file_path: row["file_path"],
          line_number: row["line_number"],
          title: row["title"],
          description: row["description"],
          suggestion: row["suggestion"],
          source: row["source"]
        )
      end
    end
  end
end

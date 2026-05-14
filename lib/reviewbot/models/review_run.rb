module Reviewbot
  module Models
    class ReviewRun
      attr_accessor :id, :pr_id, :status, :risk_level, :finding_count, :ai_model, :head_sha, :started_at, :completed_at

      RISK_LEVELS = %w[low medium high critical].freeze

      def initialize(id: nil, pr_id:, status: "pending", risk_level: "low", finding_count: 0, ai_model: nil, head_sha: nil, started_at: nil, completed_at: nil)
        @id = id
        @pr_id = pr_id
        @status = status
        @risk_level = risk_level
        @finding_count = finding_count
        @ai_model = ai_model
        @head_sha = head_sha
        @started_at = started_at
        @completed_at = completed_at
      end

      def to_hash
        {
          id: @id,
          pr_id: @pr_id,
          status: @status,
          risk_level: @risk_level,
          finding_count: @finding_count,
          ai_model: @ai_model,
          head_sha: @head_sha,
          started_at: @started_at,
          completed_at: @completed_at
        }
      end

      def self.from_row(row)
        new(
          id: row["id"],
          pr_id: row["pr_id"],
          status: row["status"],
          risk_level: row["risk_level"],
          finding_count: row["finding_count"],
          ai_model: row["ai_model"],
          head_sha: row["head_sha"],
          started_at: row["started_at"],
          completed_at: row["completed_at"]
        )
      end
    end
  end
end

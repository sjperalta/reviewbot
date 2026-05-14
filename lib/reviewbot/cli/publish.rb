module Reviewbot
  module CLI
    class Publish
      def initialize(display: nil, pr_manager: nil)
        @display = display || Reviewbot::Formatters::Terminal::Display.new
        @pr_manager = pr_manager || Reviewbot::Services::PRManager.new
      end

      def run(pr_number)
        Reviewbot::Config::Loader.new.load!

        @display.header("Publishing Review for PR ##{pr_number}")

        cache = Reviewbot::Cache::Manager.new

        pr_row = cache.database.execute(
          "SELECT pr.id, pr.repo_id, r.owner, r.name FROM pull_requests pr JOIN repositories r ON r.id = pr.repo_id WHERE pr.number = ? ORDER BY pr.id DESC LIMIT 1",
          [pr_number.to_i]
        ).first

        unless pr_row
          @display.error("No review found for PR ##{pr_number}. Run `reviewbot review #{pr_number}` first.")
          return
        end

        latest_run = cache.database.execute(
          "SELECT id, risk_level, head_sha FROM review_runs WHERE pr_id = ? ORDER BY started_at DESC LIMIT 1",
          [pr_row["id"]]
        ).first

        unless latest_run
          @display.error("No review run found for PR ##{pr_number}.")
          return
        end

        findings = cache.database.execute(
          "SELECT severity, file_path, line_number, title, description, suggestion FROM findings WHERE review_run_id = ?",
          [latest_run["id"]]
        )

        if findings.empty?
          @display.warning("No findings to publish for PR ##{pr_number}.")
          return
        end

        repo_full_name = "#{pr_row['owner']}/#{pr_row['name']}"
        summary = { text: "Reviewbot review completed", finding_counts: findings.group_by { |f| f["severity"] }.transform_values(&:size) }

        publisher = Reviewbot::GitHub::CommentPublisher.new
        publisher.publish(
          repo_full_name: repo_full_name,
          pr_number: pr_number.to_i,
          summary: summary,
          commit_id: latest_run["head_sha"],
          findings: findings.map { |f| { severity: f["severity"], file_path: f["file_path"], line_number: f["line_number"], title: f["title"], description: f["description"], suggestion: f["suggestion"] } }
        )

        @display.success("Review published to #{repo_full_name} ##{pr_number}")
      end
    end
  end
end

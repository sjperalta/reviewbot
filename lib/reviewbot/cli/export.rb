module Reviewbot
  module CLI
    class Export
      def initialize(display: nil)
        @display = display || Reviewbot::Formatters::Terminal::Display.new
      end

      def run(pr_number, options = {})
        @display.header("Exporting Review for PR ##{pr_number}")

        cache = Reviewbot::Cache::Manager.new

        pr_row = cache.database.execute(
          "SELECT pr.id, pr.title, pr.author, pr.number FROM pull_requests pr WHERE pr.number = ? ORDER BY pr.id DESC LIMIT 1",
          [pr_number.to_i]
        ).first

        unless pr_row
          @display.error("No review data found for PR ##{pr_number}.")
          return
        end

        latest_run = cache.database.execute(
          "SELECT id, risk_level FROM review_runs WHERE pr_id = ? ORDER BY started_at DESC LIMIT 1",
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

        pr_data = { number: pr_row["number"], title: pr_row["title"], author: pr_row["author"] }

        review_result = {
          risk_level: latest_run["risk_level"],
          findings: findings.map { |f| { severity: f["severity"], file: f["file_path"], line: f["line_number"], title: f["title"], description: f["description"], suggestion: f["suggestion"] } },
          missing_tests: [],
          architecture_notes: [],
          security_notes: []
        }

        output_dir = options[:output_dir] || Config::Defaults::OUTPUT_DIR
        exporter = Reviewbot::Services::ReportExporter.new
        path = exporter.export(pr_data: pr_data, review_result: review_result, output_dir: output_dir)

        @display.success("Report exported to #{path}")
        path
      end
    end
  end
end

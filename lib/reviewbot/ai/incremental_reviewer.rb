module Reviewbot
  module AI
    class IncrementalReviewer
      def initialize(engine: nil, cache: nil)
        @engine = engine || ReviewEngine.new(cache: cache)
        @cache = cache
      end

      def review(profile:, pr_data:, diff_files:, analysis:, previous_review: nil, options: nil)
        previous = previous_review || load_previous_review(pr_data[:number])

        if previous && pr_data[:head_sha] == previous[:head_sha]
          Reviewbot::Utils::Logger.info "PR unchanged since last review. Using cached results."
          return previous[:review]
        end

        if previous
          changed_files = diff_files.map(&:path)
          previous_findings = previous[:review][:findings] || []
          unchanged_findings = previous_findings.reject { |f| changed_files.include?(f[:file]) }
        end

        new_review = if pr_data.keys.size > 5 # has full pr_data
                       @engine.review(
                         profile: profile,
                         pr_data: pr_data,
                         diff_files: diff_files,
                         analysis: analysis,
                         options: options
                       )
                     else
                       @engine.generate_static_review(pr_data, diff_files, analysis)
                     end

        if unchanged_findings && !unchanged_findings.empty?
          new_review[:findings] = (unchanged_findings + (new_review[:findings] || [])).uniq { |f| "#{f[:file]}:#{f[:title]}" }
        end

        new_review
      end

      private

      def load_previous_review(pr_number)
        db = Reviewbot::Cache::Database.new.connect!
        row = db.execute(<<~SQL, [pr_number]).first
          SELECT rr.head_sha, rr.risk_level
          FROM review_runs rr
          JOIN pull_requests pr ON pr.id = rr.pr_id
          WHERE pr.number = ? AND rr.status = 'completed'
          ORDER BY rr.completed_at DESC LIMIT 1
        SQL
        return nil unless row

        run_id = db.execute("SELECT id FROM review_runs WHERE head_sha = ? ORDER BY completed_at DESC LIMIT 1", [row["head_sha"]]).first
        return nil unless run_id

        findings = db.execute("SELECT severity, file_path as file, line_number as line, title, description, suggestion FROM findings WHERE review_run_id = ?", [run_id["id"]])

        {
          head_sha: row["head_sha"],
          review: {
            risk_level: row["risk_level"],
            findings: findings.map { |f| { severity: f["severity"], file: f["file"], line: f["line"], title: f["title"], description: f["description"], suggestion: f["suggestion"] } }
          }
        }
      rescue => e
        Reviewbot::Utils::Logger.warn "Failed to load previous review: #{e.message}"
        nil
      end
    end
  end
end

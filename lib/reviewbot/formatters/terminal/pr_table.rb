module Reviewbot
  module Formatters
    module Terminal
      class PRTable
        def initialize
          @pastel = Pastel.new
        end

        def render(prs)
          return puts @pastel.yellow("No open PRs assigned for review.") if prs.nil? || prs.empty?

          rows = prs.map do |pr|
            repo = repo_from_url(pr["url"])
            [
              "##{pr["number"]}",
              pr["title"][0..60],
              repo,
              pr["author"]&.dig("login") || "unknown"
            ]
          end

          table = TTY::Table.new(
            header: [@pastel.bold("PR"), @pastel.bold("Title"), @pastel.bold("Repository"), @pastel.bold("Author")],
            rows: rows
          )

          puts table.render(:unicode, padding: [0, 1], resize: true)
        end

        def render_summary(review_result)
          return unless review_result

          findings = review_result[:findings] || []
          severity_counts = findings.group_by { |f| f[:severity] }.transform_values(&:size)

          rows = [
            ["Risk Level", review_result[:risk_level]&.upcase || "UNKNOWN"],
            ["Total Findings", findings.size.to_s]
          ]

          %w[critical high medium low].each do |sev|
            count = severity_counts[sev] || 0
            rows << ["  #{sev.capitalize}", count.to_s] if count > 0
          end

          table = TTY::Table.new(rows: rows)
          puts table.render(:unicode, padding: [0, 1])
        end
      private

      def repo_from_url(url)
        return "unknown" unless url
        match = url.match(%r{https?://github\.com/([^/]+/[^/]+)})
        match ? match[1] : "unknown"
      end
    end
  end
end
end


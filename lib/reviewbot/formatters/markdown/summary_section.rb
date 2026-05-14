module Reviewbot
  module Formatters
    module Markdown
      class SummarySection
        def generate(pr_data, review_result)
          risk = review_result[:risk_level] || "unknown"
          risk_badge = risk_badge_for(risk)
          finding_counts = review_result[:findings]&.group_by { |f| f[:severity] }&.transform_values(&:size) || {}

          summary = "## Review Summary\n\n"
          summary += "| | |\n|---|---|\n"
          summary += "| **PR** | ##{pr_data[:number]} - #{pr_data[:title]} |\n"
          summary += "| **Author** | #{pr_data[:author]} |\n"
          summary += "| **Risk Level** | #{risk_badge} |\n"
          summary += "| **Total Findings** | #{review_result[:findings]&.size || 0} |\n"

          unless finding_counts.empty?
            summary += "\n### Findings by Severity\n\n"
            summary += "| Severity | Count |\n"
            summary += "|----------|-------|\n"
            %w[critical high medium low].each do |sev|
              count = finding_counts[sev] || 0
              summary += "| #{sev.capitalize} | #{count} |\n" if count > 0
            end
          end

          summary_text = summary_body_text(review_result)
          if summary_text
            summary += "\n### Summary\n\n#{summary_text}\n"
          end

          summary
        end

        private

        def summary_body_text(review_result)
          s = review_result[:summary]
          case s
          when Hash
            s[:text] || s["text"]
          when String
            s
          else
            nil
          end
        end

        def risk_badge_for(risk)
          case risk
          when "critical" then "🔴 **CRITICAL**"
          when "high" then "🟠 **HIGH**"
          when "medium" then "🟡 **MEDIUM**"
          else "🟢 **LOW**"
          end
        end
      end
    end
  end
end

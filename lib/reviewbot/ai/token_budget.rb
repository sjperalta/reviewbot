module Reviewbot
  module AI
    class TokenBudget
      def initialize(limit: nil)
        @limit = limit || Config::Defaults::TOKEN_LIMIT
      end

      def within_limit?(text)
        estimate(text) <= @limit
      end

      def estimate(text)
        return 0 if text.nil? || text.empty?
        (text.length / 4.0).ceil
      end

      def truncate(text, max_tokens: nil)
        max = max_tokens || @limit
        estimated = estimate(text)
        return text if estimated <= max

        ratio = max.to_f / estimated
        char_limit = (text.length * ratio * 0.9).to_i
        text[0, char_limit] + "\n\n[...truncated due to token limit...]"
      end

      def prioritize_sections(sections)
        total = sections.sum { |s| estimate(s[:content]) }

        if total <= @limit
          return sections.map { |s| s[:content] }.join("\n\n")
        end

        priority_order = %i[system language repository pr_context analysis_results diff]
        ordered = sections.sort_by { |s| priority_order.index(s[:priority]) || 99 }

        result = []
        budget_remaining = @limit

        ordered.each do |section|
          section_tokens = estimate(section[:content])
          if section_tokens <= budget_remaining
            result << section[:content]
            budget_remaining -= section_tokens
          elsif budget_remaining > 200
            truncated = truncate(section[:content], max_tokens: budget_remaining - 50)
            result << truncated
            budget_remaining = 0
          end
        end

        result.join("\n\n")
      end

      def budget_remaining(text)
        @limit - estimate(text)
      end
    end
  end
end

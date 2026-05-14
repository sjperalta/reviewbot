module Reviewbot
  module AI
    class ResponseParser
      def parse(response)
        content = response[:content]

        result = try_parse_json(content)
        result ||= try_extract_from_code_block(content)
        result ||= fallback_parse(content)

        validate_parsed(result)
      end

      # Re-normalize review hashes (e.g. from cache) so :summary is always a { text:, finding_counts: } hash.
      def validate_parsed(result)
        return fallback_parse("") unless result.is_a?(Hash)

        validate(result)
      end

      private

      def try_parse_json(content)
        JSON.parse(content, symbolize_names: true)
      rescue JSON::ParserError
        nil
      end

      def try_extract_from_code_block(content)
        json_match = content.match(/```(?:json)?\s*\n(.+?)\n```/m)
        return nil unless json_match

        try_parse_json(json_match[1])
      end

      def fallback_parse(content)
        {
          summary: extract_section(content, "summary"),
          risk_level: extract_risk_level(content),
          findings: extract_findings_fallback(content),
          missing_tests: [],
          architecture_notes: [extract_section(content, "architecture")].compact,
          security_notes: [extract_section(content, "security")].compact
        }
      end

      def extract_section(content, heading)
        match = content.match(/#{heading}[:\s]*(.+?)(?=\n#{'#'}|\z)/im)
        match ? match[1].strip : nil
      end

      def extract_risk_level(content)
        match = content.match(/risk.?level[:\s]*(low|medium|high|critical)/im)
        match ? match[1].downcase : "medium"
      end

      def extract_findings_fallback(content)
        findings = []
        content.scan(/severity[:\s]*(low|medium|high|critical).*?file[:\s]*([^\n]+).*?title[:\s]*([^\n]+)/im) do
          findings << {
            severity: $1.downcase,
            file: $2.strip,
            title: $3.strip,
            description: "",
            suggestion: ""
          }
        end
        findings
      end

      def validate(result)
        result[:summary] = normalize_summary(result[:summary])
        result[:risk_level] = "medium" unless %w[low medium high critical].include?(result[:risk_level]&.to_s&.downcase)
        result[:findings] ||= []
        result[:missing_tests] ||= []
        result[:architecture_notes] ||= []
        result[:security_notes] ||= []
        result
      end

      def normalize_summary(summary)
        case summary
        when Hash
          text = summary[:text] || summary["text"]
          counts = summary[:finding_counts] || summary["finding_counts"] || {}
          { text: text || "No summary provided", finding_counts: counts }
        when String then { text: summary, finding_counts: {} }
        else { text: "No summary provided", finding_counts: {} }
        end
      end
    end
  end
end

module Reviewbot
  module Analyzers
    class BrakemanRunner < Runner
      def initialize
        super(tool_name: "brakeman")
      end

      def run(dir: nil, files: nil)
        return skip_result unless tool_installed?("brakeman")

        result = super("brakeman --format json --quiet", dir: dir)
        return result unless result.success?

        parse_output(result)
      end

      private

      def skip_result
        Models::AnalysisResult.new(tool: @tool_name, errors: ["brakeman not installed"])
      end

      def parse_output(result)
        output = result.instance_variable_get(:@output) || ""
        return result if output.empty?

        data = JSON.parse(output)
        warnings = data["warnings"] || []

        warnings.each do |warning|
          result.add_finding(
            severity: map_severity(warning["confidence"]),
            file: warning["file"],
            line: warning["line"],
            message: warning["message"],
            rule: warning["warning_type"]
          )
        end

        result
      rescue JSON::ParserError
        result
      end

      def map_severity(confidence)
        case confidence
        when "High" then "high"
        when "Medium" then "medium"
        when "Weak" then "low"
        else "medium"
        end
      end
    end
  end
end

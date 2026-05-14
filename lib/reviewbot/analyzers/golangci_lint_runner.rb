module Reviewbot
  module Analyzers
    class GolangciLintRunner < Runner
      def initialize
        super(tool_name: "golangci-lint")
      end

      def run(dir: nil, files: nil)
        return skip_result unless tool_installed?("golangci-lint")

        result = super("golangci-lint run --out-format json", dir: dir)
        return result unless result.success?

        parse_output(result)
      end

      private

      def skip_result
        Models::AnalysisResult.new(tool: @tool_name, errors: ["golangci-lint not installed"])
      end

      def parse_output(result)
        output = result.instance_variable_get(:@output) || ""
        return result if output.empty?

        data = JSON.parse(output)
        issues = data["Issues"] || []

        issues.each do |issue|
          result.add_finding(
            severity: map_severity(issue["Severity"]),
            file: issue["Pos"]&.dig("Filename") || issue["FromLinter"],
            line: issue["Pos"]&.dig("Line"),
            message: issue["Text"],
            rule: issue["FromLinter"]
          )
        end

        result
      rescue JSON::ParserError
        result
      end

      def map_severity(sev)
        case sev&.downcase
        when "error" then "high"
        when "warning" then "medium"
        else "medium"
        end
      end
    end
  end
end

module Reviewbot
  module Analyzers
    class ESLintRunner < Runner
      def initialize
        super(tool_name: "eslint")
      end

      def run(dir: nil, files: nil)
        return skip_result unless tool_installed?("eslint") || tool_installed?("npx")

        file_target = files ? files.join(" ") : "."
        cmd = tool_installed?("eslint") ? "eslint --format json #{file_target}" : "npx eslint --format json #{file_target}"
        result = super(cmd, dir: dir)
        return result unless result.success?

        parse_output(result)
      end

      private

      def skip_result
        Models::AnalysisResult.new(tool: @tool_name, errors: ["eslint not installed"])
      end

      def parse_output(result)
        output = result.instance_variable_get(:@output) || ""
        return result if output.empty?

        data = JSON.parse(output)
        data = [data] unless data.is_a?(Array)

        data.each do |file_result|
          file_path = file_result["filePath"]
          (file_result["messages"] || []).each do |msg|
            result.add_finding(
              severity: map_severity(msg["severity"]),
              file: file_path,
              line: msg["line"],
              message: msg["message"],
              rule: msg["ruleId"]
            )
          end
        end

        result
      rescue JSON::ParserError
        result
      end

      def map_severity(sev)
        case sev
        when 2 then "high"
        when 1 then "medium"
        else "low"
        end
      end
    end
  end
end

module Reviewbot
  module Analyzers
    class ReekRunner < Runner
      def initialize
        super(tool_name: "reek")
      end

      def run(dir: nil, files: nil)
        return skip_result unless tool_installed?("reek")

        file_target = files ? files.join(" ") : "."
        result = super("reek --format json #{file_target}", dir: dir)
        return result unless result.success?

        parse_output(result)
      end

      private

      def skip_result
        Models::AnalysisResult.new(tool: @tool_name, errors: ["reek not installed"])
      end

      def parse_output(result)
        output = result.instance_variable_get(:@output) || ""
        return result if output.empty?

        data = JSON.parse(output)
        if data.is_a?(Array)
          data.each do |warning|
            result.add_finding(
              severity: "medium",
              file: warning["source"],
              line: warning["lines"]&.first,
              message: warning["message"],
              rule: warning["smell_type"]
            )
          end
        end

        result
      rescue JSON::ParserError
        result
      end
    end
  end
end

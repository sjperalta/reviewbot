module Reviewbot
  module Analyzers
    class DartAnalyzerRunner < Runner
      def initialize
        super(tool_name: "dart-analyze")
      end

      def run(dir: nil, files: nil)
        return skip_result unless tool_installed?("dart")

        result = super("dart analyze", dir: dir)
        parse_output(result)
      end

      private

      def skip_result
        Models::AnalysisResult.new(tool: @tool_name, errors: ["dart not installed"])
      end

      def parse_output(result)
        output = result.instance_variable_get(:@output) || ""
        return result if output.empty?

        output.each_line do |line|
          next unless line.match?(/error|warning|info/)

          parts = line.split("•")
          location = parts[0]&.strip || ""
          message = parts[1]&.strip || ""

          loc_parts = location.split(":")
          file = loc_parts[0]&.strip || "unknown"
          line_num = loc_parts[1]&.to_i

          severity = if line.match?(/error/i)
                       "high"
                     elsif line.match?(/warning/i)
                       "medium"
                     else
                       "low"
                     end

          result.add_finding(
            severity: severity,
            file: file,
            line: line_num,
            message: message.empty? ? line.strip : message,
            rule: "dart-analyze"
          )
        end

        result
      end
    end
  end
end

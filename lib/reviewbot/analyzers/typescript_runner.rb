module Reviewbot
  module Analyzers
    class TypeScriptRunner < Runner
      def initialize
        super(tool_name: "typescript")
      end

      def run(dir: nil, files: nil)
        return skip_result unless tool_installed?("npx") || tool_installed?("tsc")

        cmd = tool_installed?("tsc") ? "tsc --noEmit" : "npx tsc --noEmit"
        result = super(cmd, dir: dir)
        parse_output(result)
      end

      private

      def skip_result
        Models::AnalysisResult.new(tool: @tool_name, errors: ["typescript compiler not installed"])
      end

      def parse_output(result)
        output = result.instance_variable_get(:@output) || ""
        return result if output.empty?

        output.each_line do |line|
          next unless line.match?(/error/i)

          parts = line.split("(")
          file_part = parts[0]&.strip
          line_num = nil

          if parts[1]
            line_match = parts[1].match(/(\d+)/)
            line_num = line_match[1].to_i if line_match
          end

          result.add_finding(
            severity: "high",
            file: file_part || "unknown",
            line: line_num,
            message: line.strip,
            rule: "typescript-error"
          )
        end

        result
      end
    end
  end
end

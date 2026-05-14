module Reviewbot
  module Analyzers
    class GoVetRunner < Runner
      def initialize
        super(tool_name: "go-vet")
      end

      def run(dir: nil, files: nil)
        return skip_result unless tool_installed?("go")

        result = super("go vet ./...", dir: dir)
        parse_output(result)
      end

      private

      def skip_result
        Models::AnalysisResult.new(tool: @tool_name, errors: ["go not installed"])
      end

      def parse_output(result)
        output = result.instance_variable_get(:@output) || ""
        return result if output.empty?

        output.each_line do |line|
          next if line.strip.empty?
          next unless line.match?(/:\d+:/)

          parts = line.split(":")
          file = parts[0]&.strip || "unknown"
          line_num = parts[1]&.to_i
          message = parts[2..]&.join(":")&.strip || ""

          result.add_finding(
            severity: "medium",
            file: file,
            line: line_num,
            message: message,
            rule: "go-vet"
          )
        end

        result
      end
    end
  end
end

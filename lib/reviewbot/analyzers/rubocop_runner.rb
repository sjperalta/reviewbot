module Reviewbot
  module Analyzers
    class RubocopRunner < Runner
      def initialize
        super(tool_name: "rubocop")
      end

      def run(dir: nil, files: nil)
        return skip_result unless tool_installed?("rubocop")

        file_target = files ? files.join(" ") : "."
        result = super("rubocop --format json #{file_target}", dir: dir)
        return result unless result.success?

        parse_output(result)
      end

      private

      def skip_result
        Models::AnalysisResult.new(tool: @tool_name, errors: ["rubocop not installed"])
      end

      def parse_output(result)
        output = result.instance_variable_get(:@output) || ""
        return result if output.empty?

        data = JSON.parse(output)
        files_result = data["files"] || []

        files_result.each do |file|
          file_path = file["path"]
          (file["offenses"] || []).each do |offense|
            result.add_finding(
              severity: map_severity(offense["severity"]),
              file: file_path,
              line: offense["location"]&.dig("line"),
              message: offense["message"],
              rule: offense["cop_name"]
            )
          end
        end

        result
      rescue JSON::ParserError
        result
      end

      def map_severity(sev)
        case sev
        when "fatal", "error" then "high"
        when "warning" then "medium"
        else "low"
        end
      end
    end
  end
end

module Reviewbot
  module Analyzers
    class Runner
      attr_reader :tool_name

      def initialize(tool_name:)
        @tool_name = tool_name
      end

      def run(command, dir: nil)
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        Reviewbot::Utils::Logger.info "Running #{@tool_name}..."

        dir_cmd = dir ? "cd #{dir} && " : ""
        full_cmd = "#{dir_cmd}#{command} 2>&1"
        output = `#{full_cmd}`
        exit_status = $?.exitstatus

        duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).to_i

        Models::AnalysisResult.new(
          tool: @tool_name,
          duration_ms: duration_ms
        )
      rescue => e
        Models::AnalysisResult.new(tool: @tool_name, errors: [e.message])
      end

      def tool_installed?(name)
        `which #{name} 2>/dev/null`
        $?.success?
      end
    end
  end
end

module Reviewbot
  module Models
    class AnalysisResult
      attr_reader :tool, :files, :findings, :errors, :duration_ms

      def initialize(tool:, files: [], findings: [], errors: [], duration_ms: 0)
        @tool = tool
        @files = files
        @findings = findings
        @errors = errors
        @duration_ms = duration_ms
      end

      def success?
        @errors.empty?
      end

      def finding_count
        @findings.size
      end

      def add_finding(severity:, file:, line: nil, message:, rule: nil)
        @findings << {
          tool: @tool,
          severity: severity,
          file: file,
          line: line,
          message: message,
          rule: rule
        }
      end

      def to_hash
        {
          tool: @tool,
          files: @files,
          findings: @findings,
          errors: @errors,
          duration_ms: @duration_ms,
          success: success?,
          finding_count: finding_count
        }
      end
    end
  end
end

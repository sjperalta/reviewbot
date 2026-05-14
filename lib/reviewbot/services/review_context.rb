module Reviewbot
  module Services
    class ReviewContext
      attr_reader :profile, :pr_metadata, :diff_files, :analysis_results, :repo_config, :options

      def initialize(profile:, pr_metadata: {}, diff_files: [], analysis_results: nil, repo_config: nil, options: nil)
        @profile = profile
        @pr_metadata = pr_metadata
        @diff_files = diff_files
        @analysis_results = analysis_results
        @repo_config = repo_config
        @options = options
      end

      def source_diffs
        @diff_files.select(&:source?)
      end

      def test_diffs
        @diff_files.select(&:test?)
      end

      def analysis_findings
        @analysis_results&.findings || []
      end

      def has_analysis?
        @analysis_results && !@analysis_results.findings.empty?
      end

      def missing_deepseek_key?
        !options&.ai_enabled? && options
      end

      def to_h
        {
          profile: @profile.to_hash,
          pr_metadata: @pr_metadata,
          file_count: @diff_files.size,
          source_count: source_diffs.size,
          test_count: test_diffs.size,
          analysis_count: analysis_findings.size,
          has_analysis: has_analysis?
        }
      end
    end
  end
end

module Reviewbot
  module Services
    class PipelineOrchestrator
      def initialize(cache: nil, ai_engine: nil)
        @cache = cache || Reviewbot::Cache::Manager.new
        @ai_engine = ai_engine
      end

      def run(pr_data:, options:, &progress_block)
        phases = [
          { name: "detecting", task: -> { detect_repository(pr_data, options) } },
          { name: "diffing", task: -> { extract_diff(pr_data) } },
          { name: "analyzing", task: -> { run_analysis(pr_data) } },
          { name: "reviewing", task: -> { run_review(pr_data, options) } }
        ]

        results = {}
        phases.each do |phase|
          report_progress(progress_block, phase[:name], :start)
          results[phase[:name].to_sym] = phase[:task].call
          report_progress(progress_block, phase[:name], :complete)
        end

        store_results(pr_data, results)

        results
      end

      private

      def report_progress(block, phase, status)
        block&.call(phase, status)
      end

      def detect_repository(pr_data, options)
        detector = RepoDetector.new
        if options&.stack && !options.stack.empty?
          Reviewbot::Models::RepoProfile.new(
            primary_stack: options.stack.first,
            stacks: options.stack,
            languages: options.stack,
            frameworks: options.stack
          )
        else
          detector.detect(pr_data[:repo_path])
        end
      end

      def extract_diff(pr_data)
        extractor = DiffExtractor.new
        files = extractor.extract(
          repo_path: pr_data[:repo_path],
          base_branch: pr_data[:base_branch],
          head_branch: pr_data[:head_branch]
        )
        categorizer = FileCategorizer.new
        categorizer.categorize(files)
        files
      end

      def run_analysis(pr_data)
        orchestrator = Reviewbot::Analyzers::Orchestrator.new
        profile = Reviewbot::Models::RepoProfile.new(stacks: [])
        orchestrator.analyze(profile, dir: pr_data[:repo_path])
      end

      def run_review(pr_data, options)
        if @ai_engine
          profile = Reviewbot::Models::RepoProfile.new(stacks: [])
          @ai_engine.review(
            profile: profile,
            pr_data: pr_data,
            diff_files: [],
            analysis: nil,
            options: options
          )
        else
          Reviewbot::Utils::Logger.warn "AI engine not configured"
          nil
        end
      end

      def store_results(pr_data, results)
        # results stored by ReviewCoordinator
      end
    end
  end
end

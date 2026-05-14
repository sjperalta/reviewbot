module Reviewbot
  module Analyzers
    class Orchestrator
      ANALYZER_MAP = {
        "rails" => [:rubocop, :brakeman, :reek],
        "ruby" => [:rubocop, :reek],
        "typescript" => [:eslint, :typescript],
        "javascript" => [:eslint],
        "react" => [:eslint],
        "flutter" => [:dart_analyze],
        "dart" => [:dart_analyze],
        "go" => [:golangci_lint, :go_vet]
      }.freeze

      def initialize
        @runners = {
          rubocop: Analyzers::RubocopRunner.new,
          brakeman: Analyzers::BrakemanRunner.new,
          reek: Analyzers::ReekRunner.new,
          eslint: Analyzers::ESLintRunner.new,
          typescript: Analyzers::TypeScriptRunner.new,
          dart_analyze: Analyzers::DartAnalyzerRunner.new,
          golangci_lint: Analyzers::GolangciLintRunner.new,
          go_vet: Analyzers::GoVetRunner.new
        }
      end

      def analyze(profile, dir:, files: nil)
        runner_keys = select_runners(profile)
        results = run_analyzers(runner_keys, dir: dir, files: files)
        merge_results(results)
      end

      def analyze_all(profile, dir:)
        runner_keys = ANALYZER_MAP.values.flatten.uniq
        results = run_analyzers(runner_keys, dir: dir)
        merge_results(results)
      end

      private

      def select_runners(profile)
        keys = []
        profile.stacks.each do |stack|
          keys.concat(ANALYZER_MAP[stack] || [])
        end
        keys.uniq
      end

      def run_analyzers(keys, dir:, files: nil)
        pool = Concurrent::ThreadPoolExecutor.new(max_threads: [keys.size, 4].min)
        promises = keys.map do |key|
          runner = @runners[key]
          Concurrent::Promise.execute(executor: pool) do
            runner.run(dir: dir, files: files)
          end
        end

        promises.map(&:value!)
      rescue => e
        Reviewbot::Utils::Logger.error "Analysis error: #{e.message}"
        keys.map { |k| Models::AnalysisResult.new(tool: k.to_s, errors: [e.message]) }
      end

      def merge_results(results)
        all_findings = results.flat_map { |r| r.findings }
        all_errors = results.flat_map { |r| r.errors }.compact
        total_duration = results.sum { |r| r.duration_ms }

        Models::AnalysisResult.new(
          tool: "combined",
          findings: all_findings,
          errors: all_errors,
          duration_ms: total_duration
        )
      end
    end
  end
end

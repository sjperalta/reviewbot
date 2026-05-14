module Reviewbot
  module Services
    class ReviewCoordinator
      def initialize(cache: nil, detector: nil, analyzer: nil, ai_engine: nil, exporter: nil)
        @cache = cache || Reviewbot::Cache::Manager.new
        @detector = detector || RepoDetector.new
        @analyzer = analyzer || Reviewbot::Analyzers::Orchestrator.new
        @ai_engine = ai_engine
        @exporter = exporter || ReportExporter.new
      end

      def review_pr(pr_data:, options:)
        repo_path = pr_data[:repo_path]
        pr_number = pr_data[:number]

        profile = detect_repository(repo_path, options)
        return nil unless profile

        diff_files = extract_diff(repo_path, pr_data, profile)
        return nil if diff_files.empty?

        analysis = run_analysis(profile, repo_path, diff_files)

        review_result = run_ai_review(profile, pr_data, diff_files, analysis, options)

        store_results(pr_data, profile, review_result)

        review_result
      end

      def review_all(prs_data:, options:)
        prs_data.map do |pr_data|
          Reviewbot::Utils::Logger.info "Reviewing PR ##{pr_data[:number]}"
          review_pr(pr_data: pr_data, options: options)
        end.compact
      end

      private

      def detect_repository(repo_path, options)
        if options&.stack && !options.stack.empty?
          stacks = options.stack
          profile = Reviewbot::Models::RepoProfile.new(
            primary_stack: stacks.first,
            stacks: stacks,
            languages: stacks,
            frameworks: stacks
          )
          Reviewbot::Utils::Logger.info "Using configured stack: #{stacks.join(', ')}"
          return profile
        end

        profile = @detector.detect(repo_path)
        Reviewbot::Utils::Logger.info "Detected stack: #{profile.primary_stack} (#{profile.stacks.join(', ')})"
        profile
      end

      def extract_diff(repo_path, pr_data, profile)
        extractor = DiffExtractor.new
        diff_files = extractor.extract(
          repo_path: repo_path,
          base_branch: pr_data[:base_branch],
          head_branch: pr_data[:head_branch],
          head_sha: pr_data[:head_sha]
        )

        categorizer = FileCategorizer.new
        categorizer.categorize(diff_files)

        chunker = DiffChunker.new
        chunks = chunker.chunk(diff_files)

        chunks.flat_map(&:files)
      end

      def run_analysis(profile, repo_path, diff_files)
        source_files = diff_files.select(&:source?).map(&:path)
        @analyzer.analyze(profile, dir: repo_path, files: source_files)
      end

      def run_ai_review(profile, pr_data, diff_files, analysis, options)
        if @ai_engine
          @ai_engine.review(
            profile: profile,
            pr_data: pr_data,
            diff_files: diff_files,
            analysis: analysis,
            options: options
          )
        else
          generate_offline_review(pr_data, diff_files, analysis)
        end
      end

      def generate_offline_review(pr_data, diff_files, analysis)
        findings = analysis&.findings || []
        formatted = findings.map do |f|
          {
            severity: f[:severity],
            file: f[:file],
            line: f[:line],
            title: "[#{f[:tool]}] #{f[:message]}",
            description: f[:message],
            suggestion: "Review and fix this issue flagged by #{f[:tool]}"
          }
        end

        severity_counts = formatted.each_with_object(Hash.new(0)) { |f, h| h[f[:severity]] += 1 }

        {
          summary: {
            text: "Static analysis review for PR ##{pr_data[:number]}: #{pr_data[:title]}",
            finding_counts: severity_counts
          },
          risk_level: severity_counts["high"] > 0 ? "high" : (severity_counts["medium"] > 0 ? "medium" : "low"),
          findings: formatted,
          missing_tests: [],
          architecture_notes: [],
          security_notes: formatted.select { |f| f[:severity] == "high" || f[:severity] == "critical" }
        }
      end

      def store_results(pr_data, profile, review_result)
        repo = @cache.repositories.find_or_create(
          owner: pr_data[:repo_full_name]&.split("/")&.first || "unknown",
          name: pr_data[:repo_full_name]&.split("/")&.last || "unknown",
          remote_url: "https://github.com/#{pr_data[:repo_full_name]}",
          local_path: pr_data[:repo_path]
        )
        @cache.repositories.update_stack_profile(repo.id, profile)

        pr = @cache.pull_requests.find_or_create(
          repo_id: repo.id,
          number: pr_data[:number],
          title: pr_data[:title],
          author: pr_data[:author] || "unknown",
          base_branch: pr_data[:base_branch],
          head_branch: pr_data[:head_branch],
          head_sha: pr_data[:head_sha]
        )

        run = @cache.review_runs.create(
          pr_id: pr.id,
          head_sha: pr_data[:head_sha],
          ai_model: "static-analysis"
        )

        review_result[:findings].each do |f|
          @cache.findings.create(
            review_run_id: run.id,
            severity: f[:severity],
            category: "bug",
            file_path: f[:file],
            line_number: f[:line],
            title: f[:title],
            description: f[:description],
            suggestion: f[:suggestion],
            source: "static-analysis"
          )
        end

        @cache.review_runs.complete(run.id, risk_level: review_result[:risk_level], finding_count: review_result[:findings].size)
      end
    end
  end
end

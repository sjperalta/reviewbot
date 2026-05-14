module Reviewbot
  module AI
    class ReviewEngine
      def initialize(client: nil, retry_handler: nil, prompt_builder: nil, parser: nil, cache: nil)
        @client = client || Client.new
        @retry_handler = retry_handler || RetryHandler.new
        @prompt_builder = prompt_builder || PromptBuilder.new
        @parser = parser || ResponseParser.new
        @cache = cache
      end

      def review(profile:, pr_data:, diff_files:, analysis:, options: nil)
        unless @client.available?
          Reviewbot::Utils::Logger.warn "DeepSeek API key not configured. Skipping AI review."
          return generate_static_review(pr_data, diff_files, analysis)
        end

        pr_number = pr_data[:number]
        head_sha = pr_data[:head_sha]

        cached = check_cache(pr_number, head_sha)
        return cached if cached

        messages = @prompt_builder.build_assemble(
          profile: profile,
          pr_data: pr_data,
          diff_files: diff_files,
          analysis: analysis,
          repo_config: options&.repo_config
        )

        Reviewbot::Utils::Logger.info "Sending review request to DeepSeek..."
        response = @retry_handler.with_retry do |attempt|
          @client.chat(messages)
        end

        result = @parser.parse(response)

        save_to_cache(pr_number, head_sha, result)

        result
      rescue Utils::ErrorHandler::APIError, Utils::ErrorHandler::NetworkError => e
        Reviewbot::Utils::Logger.error "AI review failed: #{e.message}"
        generate_static_review(pr_data, diff_files, analysis)
      end

      private

      def check_cache(pr_number, head_sha)
        return nil unless @cache

        raw = @cache.get(pr_number, head_sha)&.dig(:data)
        return nil unless raw.is_a?(Hash)

        @parser.validate_parsed(raw)
      end

      def save_to_cache(pr_number, head_sha, result)
        return unless @cache
        @cache.set(pr_number: pr_number, head_sha: head_sha, review_data: result)
      end

      def generate_static_review(pr_data, diff_files, analysis)
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
          security_notes: formatted.select { |f| %w[high critical].include?(f[:severity]) }
        }
      end
    end
  end
end

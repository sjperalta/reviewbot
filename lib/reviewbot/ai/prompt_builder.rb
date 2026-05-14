module Reviewbot
  module AI
    class PromptBuilder
      SYSTEM_PROMPT = <<~PROMPT.freeze
        You are an expert code reviewer with deep knowledge of software engineering best practices, design patterns, security, and performance optimization.

        Review Philosophy:
        - Focus on issues that matter: security vulnerabilities, performance problems, correctness bugs, and design issues
        - Ignore stylistic preferences and minor formatting issues
        - Be constructive and specific in your suggestions
        - Consider the broader architecture, not just the changed lines
        - Flag missing tests for new or modified functionality

        Severity Model:
        - CRITICAL: Security vulnerabilities, data loss, production outage risks
        - HIGH: Correctness bugs, performance regressions, significant architectural issues
        - MEDIUM: Maintainability concerns, minor bugs, code smells
        - LOW: Suggestions for improvement, style consistency

        Output Format:
        Return your review as a valid JSON object with this exact structure:
        {
          "summary": "Brief 2-3 sentence overview of the PR changes and the main concerns.",
          "risk_level": "low|medium|high|critical",
          "findings": [
            {
              "severity": "low|medium|high|critical",
              "file": "path/to/file.rb",
              "line": 42,
              "title": "Short descriptive title",
              "description": "Detailed explanation of the issue, why it matters, and potential impact.",
              "suggestion": "Concrete suggestion for how to fix or improve this."
            }
          ],
          "missing_tests": [
            {
              "file": "path/to/file.rb",
              "reason": "Why this file appears to need tests"
            }
          ],
          "architecture_notes": [
            "Observation about the broader architecture impact"
          ],
          "security_notes": [
            "Security-relevant observation or finding"
          ]
        }
        Only include files and findings that are relevant. Return an empty array for sections with no findings.
      PROMPT

      def initialize(token_budget: nil)
        @token_budget = token_budget || TokenBudget.new
      end

      def build_system_prompt
        { role: "system", content: SYSTEM_PROMPT }
      end

      def build_language_prompt(profile)
        prompt = generate_language_prompt(profile)
        { role: "system", content: prompt }
      end

      def build_repository_prompt(repo_config)
        return nil unless repo_config&.exists?

        rules = repo_config.rules
        return nil if rules.empty?

        content = "Repository-specific review rules:\n"
        rules.each do |key, value|
          content += "- #{key}: #{value}\n"
        end

        { role: "system", content: content }
      end

      def build_pr_context_prompt(pr_data:, diff_files:, analysis:)
        content = ""

        content += "## Pull Request\n\n"
        content += "Title: #{pr_data[:title]}\n" if pr_data[:title]
        content += "Author: #{pr_data[:author]}\n" if pr_data[:author]
        content += "Description: #{pr_data[:description] || pr_data[:body]}\n\n"

        content += "## Changed Files\n\n"
        diff_files.each do |file|
          content += "### #{file.path} (#{file.status}, +#{file.additions}/-#{file.deletions})\n"
          content += "```#{file.path.split('.').last}\n#{file.patch}\n```\n\n" if file.patch
        end

        if analysis && !analysis.findings.empty?
          content += "## Static Analysis Results\n\n"
          analysis.findings.group_by { |f| f[:file] }.each do |file, findings|
            content += "### #{file}\n"
            findings.each do |f|
              content += "- [#{f[:severity]}] #{f[:tool]}: #{f[:message]}"
              content += " (line #{f[:line]})" if f[:line]
              content += "\n"
            end
          end
          content += "\n"
        end

        { role: "user", content: content }
      end

      def build_assemble(profile:, pr_data:, diff_files:, analysis:, repo_config: nil)
        messages = [build_system_prompt]
        messages << build_language_prompt(profile)

        repo_prompt = build_repository_prompt(repo_config)
        messages << repo_prompt if repo_prompt

        messages << build_pr_context_prompt(
          pr_data: pr_data,
          diff_files: diff_files,
          analysis: analysis
        )

        sections = messages.map do |m|
          { priority: role_priority(m[:role]), content: "#{m[:role].upcase}: #{m[:content]}" }
        end

        assembled = @token_budget.prioritize_sections(sections)

        [build_system_prompt] + messages[1..]
      end

      private

      def role_priority(role)
        case role
        when "system" then :system
        when "language" then :language
        when "repository" then :repository
        when "user" then :pr_context
        else :pr_context
        end
      end

      def generate_language_prompt(profile)
        case profile.primary_stack
        when "rails"
          rails_prompt
        when "ruby"
          ruby_prompt
        when "react"
          react_prompt
        when "typescript"
          typescript_prompt
        when "javascript"
          javascript_prompt
        when "flutter"
          flutter_prompt
        when "dart"
          dart_prompt
        when "go"
          go_prompt
        else
          general_prompt
        end
      end

      def rails_prompt
        <<~PROMPT
          You are reviewing a Ruby on Rails application. Focus on:
          - N+1 queries and eager loading (use includes, preload, eager_load)
          - Database transaction safety and atomicity
          - ActiveRecord callback abuse (prefer service objects)
          - Fat controllers (logic should be in models or service objects)
          - Strong parameters and mass assignment protection
          - Background job safety (idempotency, error handling)
          - Authorization checks (Pundit, CanCanCan)
          - Security: SQL injection, XSS, CSRF, mass assignment
          - Migration safety for production (avoid locking large tables)
          - View layer: avoid complex logic in views/helpers
        PROMPT
      end

      def ruby_prompt
        <<~PROMPT
          You are reviewing a Ruby project. Focus on:
          - Proper error handling (avoid rescue Exception)
          - Memory and object allocation concerns
          - Thread safety in concurrent code
          - Proper use of blocks and enumerables
          - Avoiding monkey-patching when possible
          - Nil checking and safe navigation
          - Performance: avoid O(n^2) patterns in loops
          - Idiomatic Ruby: prefer expressive, readable code
        PROMPT
      end

      def react_prompt
        <<~PROMPT
          You are reviewing a React application. Focus on:
          - React hooks rules (don't call hooks conditionally)
          - Unnecessary re-renders (memo, useMemo, useCallback)
          - State management: avoid prop drilling, use context or proper state management
          - Key props in lists
          - Effect dependencies (complete deps array)
          - Avoiding direct DOM manipulation
          - Component composition patterns
          - Performance: virtualization for long lists
          - TypeScript: proper typing of props and state
        PROMPT
      end

      def typescript_prompt
        <<~PROMPT
          You are reviewing a TypeScript project. Focus on:
          - Type safety: avoid 'any', use proper generics
          - Strict mode compliance
          - Proper discriminated unions and type narrowing
          - Async/await error handling
          - Null/undefined safety
          - Interface vs type usage
          - Module organization and import hygiene
          - Utility types for better abstractions
        PROMPT
      end

      def javascript_prompt
        <<~PROMPT
          You are reviewing a JavaScript project. Focus on:
          - Async/await error handling and promise chains
          - Avoiding callback hell and nesting
          - Proper use of modern ES features
          - Module patterns and imports
          - Memory leaks from closures and event listeners
          - Type coercion bugs
          - Performance: debouncing, throttling
          - Equality checks (=== over ==)
        PROMPT
      end

      def flutter_prompt
        <<~PROMPT
          You are reviewing a Flutter/Dart project. Focus on:
          - Widget rebuild optimization (const constructors)
          - State management consistency (Bloc/Provider/Riverpod)
          - Async context and widget lifecycle (mounted checks)
          - Memory leaks from streams and controllers
          - Navigation architecture and deep linking
          - Platform channel safety
          - Proper dispose patterns
          - Null safety best practices
        PROMPT
      end

      def dart_prompt
        <<~PROMPT
          You are reviewing a Dart project. Focus on:
          - Null safety: proper use of ? and ! operators
          - Async patterns: proper Future handling
          - Stream subscription management
          - Effective Dart style and idioms
          - Immutability with final/const
          - Error handling with try/catch
        PROMPT
      end

      def go_prompt
        <<~PROMPT
          You are reviewing a Go project. Focus on:
          - Goroutine leaks and proper lifecycle management
          - Context propagation and cancellation
          - Error handling: check errors, proper wrapping
          - Interface design and composition
          - Concurrency: mutexes, channels, WaitGroups
          - Transaction safety in database operations
          - Proper use of defer
          - Avoiding shadowed variables
          - Test table-driven tests
        PROMPT
      end

      def general_prompt
        <<~PROMPT
          You are reviewing a general-purpose code change. Focus on:
          - Correctness: logic errors, edge cases
          - Error handling: proper error propagation
          - Security: injection, auth, data exposure
          - Performance: algorithm complexity, resource usage
          - Maintainability: clear naming, single responsibility
          - Testing: adequate test coverage for changes
        PROMPT
      end
    end
  end
end

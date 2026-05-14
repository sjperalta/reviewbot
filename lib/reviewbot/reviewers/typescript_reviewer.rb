module Reviewbot
  module Reviewers
    class TypeScriptReviewer < Base
      def initialize
        super(name: "typescript")
      end

      def analyzers
        [:eslint, :typescript]
      end

      def applicable?(profile)
        profile.typescript?
      end

      def language_prompt
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

      def review_focus
        [
          "type safety",
          "strict mode",
          "type narrowing",
          "null safety"
        ]
      end
    end
  end
end

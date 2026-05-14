module Reviewbot
  module Reviewers
    class DartReviewer < Base
      def initialize
        super(name: "dart")
      end

      def analyzers
        [:dart_analyze]
      end

      def applicable?(profile)
        profile.dart? && !profile.flutter?
      end

      def language_prompt
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

      def review_focus
        [
          "null safety",
          "async patterns",
          "stream management",
          "error handling"
        ]
      end
    end
  end
end

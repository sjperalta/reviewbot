module Reviewbot
  module Reviewers
    class FlutterReviewer < Base
      def initialize
        super(name: "flutter")
      end

      def analyzers
        [:dart_analyze]
      end

      def applicable?(profile)
        profile.flutter?
      end

      def language_prompt
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

      def review_focus
        [
          "widget rebuilds",
          "state management",
          "memory leaks",
          "navigation",
          "dispose patterns"
        ]
      end
    end
  end
end

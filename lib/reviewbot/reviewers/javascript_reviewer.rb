module Reviewbot
  module Reviewers
    class JavaScriptReviewer < Base
      def initialize
        super(name: "javascript")
      end

      def analyzers
        [:eslint]
      end

      def applicable?(profile)
        profile.javascript?
      end

      def language_prompt
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

      def review_focus
        [
          "async error handling",
          "memory leaks",
          "module patterns",
          "performance"
        ]
      end
    end
  end
end

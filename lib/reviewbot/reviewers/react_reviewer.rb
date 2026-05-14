module Reviewbot
  module Reviewers
    class ReactReviewer < Base
      def initialize
        super(name: "react")
      end

      def analyzers
        [:eslint]
      end

      def applicable?(profile)
        profile.react?
      end

      def language_prompt
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

      def review_focus
        [
          "hooks rules",
          "re-render optimization",
          "state management",
          "effect deps"
        ]
      end
    end
  end
end

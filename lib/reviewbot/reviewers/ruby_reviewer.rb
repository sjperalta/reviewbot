module Reviewbot
  module Reviewers
    class RubyReviewer < Base
      def initialize
        super(name: "ruby")
      end

      def analyzers
        [:rubocop, :reek]
      end

      def applicable?(profile)
        profile.ruby?
      end

      def language_prompt
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

      def review_focus
        [
          "error handling patterns",
          "memory allocation",
          "thread safety",
          "idiomatic Ruby",
          "nil safety"
        ]
      end
    end
  end
end

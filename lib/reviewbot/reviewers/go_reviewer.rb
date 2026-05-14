module Reviewbot
  module Reviewers
    class GoReviewer < Base
      def initialize
        super(name: "go")
      end

      def analyzers
        [:golangci_lint, :go_vet]
      end

      def applicable?(profile)
        profile.go?
      end

      def language_prompt
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

      def review_focus
        [
          "goroutine leaks",
          "context propagation",
          "error handling",
          "concurrency safety",
          "idiomatic Go"
        ]
      end
    end
  end
end

module Reviewbot
  module Reviewers
    class RailsReviewer < Base
      def initialize
        super(name: "rails")
      end

      def analyzers
        [:rubocop, :brakeman, :reek]
      end

      def applicable?(profile)
        profile.rails?
      end

      def language_prompt
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

      def review_focus
        [
          "N+1 queries",
          "transaction safety",
          "callback abuse",
          "fat controllers",
          "authorization",
          "security"
        ]
      end
    end
  end
end

module Reviewbot
  module Reviewers
    class ReviewerFactory
      REVIEWERS = [
        RailsReviewer.new,
        RubyReviewer.new,
        ReactReviewer.new,
        TypeScriptReviewer.new,
        JavaScriptReviewer.new,
        FlutterReviewer.new,
        DartReviewer.new,
        GoReviewer.new
      ].freeze

      def self.for_profile(profile)
        REVIEWERS.select { |r| r.applicable?(profile) }
      end

      def self.primary_for_profile(profile)
        REVIEWERS.find { |r| r.applicable?(profile) && r.name == profile.primary_stack } ||
          REVIEWERS.find { |r| r.applicable?(profile) }
      end

      def self.analyzers_for_profile(profile)
        reviewers = for_profile(profile)
        reviewers.flat_map(&:analyzers).uniq
      end

      def self.prompt_for_profile(profile)
        reviewer = primary_for_profile(profile)
        reviewer&.language_prompt
      end
    end
  end
end

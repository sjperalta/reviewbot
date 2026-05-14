module Reviewbot
  module Pipelines
    class RubyPipeline < Base
      def initialize
        super(name: "ruby", reviewer: Reviewers::RubyReviewer.new)
      end

      def run(pr_data:, repo_path:, options:)
        Reviewbot::Utils::Logger.info "Running Ruby review pipeline"
        { pipeline: @name, status: "completed" }
      end

      def applicable?(profile)
        profile.ruby?
      end
    end
  end
end

module Reviewbot
  module Pipelines
    class GoPipeline < Base
      def initialize
        super(name: "go", reviewer: Reviewers::GoReviewer.new)
      end

      def run(pr_data:, repo_path:, options:)
        Reviewbot::Utils::Logger.info "Running Go review pipeline"
        { pipeline: @name, status: "completed" }
      end

      def applicable?(profile)
        profile.go?
      end
    end
  end
end

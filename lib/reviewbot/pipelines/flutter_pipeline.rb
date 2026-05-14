module Reviewbot
  module Pipelines
    class FlutterPipeline < Base
      def initialize
        super(name: "flutter", reviewer: Reviewers::FlutterReviewer.new)
      end

      def run(pr_data:, repo_path:, options:)
        Reviewbot::Utils::Logger.info "Running Flutter review pipeline"
        { pipeline: @name, status: "completed" }
      end

      def applicable?(profile)
        profile.flutter?
      end
    end
  end
end

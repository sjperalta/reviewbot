module Reviewbot
  module Pipelines
    class NodePipeline < Base
      def initialize
        super(name: "node", reviewer: nil)
      end

      def run(pr_data:, repo_path:, options:)
        Reviewbot::Utils::Logger.info "Running Node.js review pipeline"
        { pipeline: @name, status: "completed" }
      end

      def applicable?(profile)
        profile.node?
      end
    end
  end
end

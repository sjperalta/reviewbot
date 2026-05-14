module Reviewbot
  module Pipelines
    class Base
      def initialize(name:, reviewer: nil)
        @name = name
        @reviewer = reviewer
      end

      def run(pr_data:, repo_path:, options:)
        raise NotImplementedError
      end

      def applicable?(profile)
        false
      end
    end
  end
end

module Reviewbot
  module Reviewers
    class Base
      attr_reader :name

      def initialize(name:)
        @name = name
      end

      def detect(repo_path)
        raise NotImplementedError
      end

      def analyzers
        raise NotImplementedError
      end

      def language_prompt
        raise NotImplementedError
      end

      def review_focus
        raise NotImplementedError
      end

      def applicable?(profile)
        false
      end
    end
  end
end

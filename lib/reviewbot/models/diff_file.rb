module Reviewbot
  module Models
    class DiffFile
      attr_accessor :path, :status, :additions, :deletions, :patch, :category

      CATEGORIES = %w[source test config generated binary vendor lockfile snapshot unknown].freeze

      def initialize(path:, status: "modified", additions: 0, deletions: 0, patch: nil, category: "unknown")
        @path = path
        @status = status
        @additions = additions
        @deletions = deletions
        @patch = patch
        @category = category
      end

      def source?
        @category == "source"
      end

      def test?
        @category == "test"
      end

      def excludable?
        %w[generated binary vendor lockfile snapshot].include?(@category)
      end

      def change_size
        @additions + @deletions
      end

      def to_hash
        {
          path: @path,
          status: @status,
          additions: @additions,
          deletions: @deletions,
          patch: @patch,
          category: @category
        }
      end
    end
  end
end

module Reviewbot
  module Models
    class DiffChunk
      attr_reader :files, :token_estimate, :priority_score

      def initialize(files: [], token_estimate: 0, priority_score: 0)
        @files = files
        @token_estimate = token_estimate
        @priority_score = priority_score
      end

      def add_file(file)
        @files << file
        @token_estimate += estimate_tokens(file)
        recalculate_priority
      end

      def exceeds_limit?(limit)
        @token_estimate > limit
      end

      def empty?
        @files.empty?
      end

      def to_hash
        {
          files: @files.map(&:to_hash),
          token_estimate: @token_estimate,
          priority_score: @priority_score
        }
      end

      private

      def estimate_tokens(file)
        return 0 unless file.patch
        (file.patch.length / 4.0).ceil + 50
      end

      def recalculate_priority
        source_count = @files.count(&:source?)
        @priority_score = source_count * 10 + @files.size
      end
    end
  end
end

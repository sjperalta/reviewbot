module Reviewbot
  module Services
    class DiffChunker
      def initialize(token_budget: nil)
        @token_budget = token_budget || Config::Defaults::TOKEN_LIMIT
      end

      def chunk(files)
        categorized = FileCategorizer.new.categorize(files)
        filtered = DiffFilter.new.filter(categorized)
        return [] if filtered.empty?

        source_files = filtered.select(&:source?)
        test_files = filtered.select(&:test?)
        other_files = filtered.reject { |f| f.source? || f.test? }

        ordered = source_files.sort_by(&:change_size).reverse +
          test_files.sort_by(&:change_size).reverse +
          other_files.sort_by(&:change_size).reverse

        chunks = build_chunks(ordered)
        chunks
      end

      private

      def build_chunks(files)
        chunks = []
        current = Models::DiffChunk.new

        files.each do |file|
          estimated = estimate_tokens(file)

          if current.exceeds_limit?(@token_budget - estimated) && !current.empty?
            chunks << current
            current = Models::DiffChunk.new
          end

          current.add_file(file)
        end

        chunks << current unless current.empty?
        chunks
      end

      def estimate_tokens(file)
        return 100 unless file.patch
        (file.patch.length / 4.0).ceil + 100
      end
    end
  end
end

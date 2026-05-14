module Reviewbot
  module Services
    class DiffFilter
      def initialize(repo_config: nil)
        @repo_config = repo_config
      end

      def filter(files)
        files.reject { |f| should_exclude?(f) }
      end

      def source_files(files)
        filter(files).select(&:source?)
      end

      def test_files(files)
        filter(files).select(&:test?)
      end

      private

      def should_exclude?(file)
        return true if file.patch.nil? || file.patch.empty?
        return true if file.excludable?

        if @repo_config&.exists?
          return true if @repo_config.should_ignore?(file.path)
        end

        false
      end
    end
  end
end

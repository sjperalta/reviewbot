module Reviewbot
  module Cache
    class Manager
      attr_reader :database, :repositories, :pull_requests, :review_runs, :findings, :diff_cache

      def initialize(db: nil)
        @database = db || Database.new
        @database.connect!
        @repositories = Repository.new(db: @database)
        @pull_requests = PullRequest.new(db: @database)
        @review_runs = ReviewRun.new(db: @database)
        @findings = Finding.new(db: @database)
        @diff_cache = DiffCache.new(db: @database)
      end

      def clear_caches!
        @diff_cache.clear!
      end

      def disconnect!
        @database.disconnect!
      end
    end
  end
end

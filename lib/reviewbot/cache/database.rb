module Reviewbot
  module Cache
    class Database
      SCHEMA_VERSION = 1

      def initialize(path: nil)
        @path = path || Config::Defaults::DB_PATH
        @conn = nil
      end

      def connect!
        FileUtils.mkdir_p(File.dirname(@path))
        @conn = SQLite3::Database.new(@path)
        @conn.results_as_hash = true
        @conn.execute("PRAGMA journal_mode=WAL")
        @conn.execute("PRAGMA foreign_keys=ON")
        migrate! if needs_migration?
        self
      end

      def connection
        @conn || connect!
      end

      def disconnect!
        @conn&.close
        @conn = nil
      end

      def execute(sql, params = [])
        connection.execute(sql, params)
      end

      def transaction(&block)
        connection.transaction(&block)
      end

      private

      def needs_migration?
        result = @conn.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='schema_version'")
        if result.empty?
          return true
        end
        version = @conn.get_first_value("SELECT version FROM schema_version LIMIT 1")
        version < SCHEMA_VERSION
      end

      def migrate!
        @conn.transaction do
          @conn.execute("CREATE TABLE IF NOT EXISTS schema_version (version INTEGER PRIMARY KEY)")
          current = @conn.get_first_value("SELECT version FROM schema_version LIMIT 1") || 0

          if current < 1
            apply_v1_schema
            @conn.execute("INSERT OR REPLACE INTO schema_version (version) VALUES (?)", [SCHEMA_VERSION])
          end
        end
      end

      def apply_v1_schema
        @conn.execute(<<~SQL)
          CREATE TABLE IF NOT EXISTS repositories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            owner TEXT NOT NULL,
            name TEXT NOT NULL,
            remote_url TEXT NOT NULL,
            local_path TEXT,
            stack_profile TEXT,
            created_at TEXT DEFAULT (datetime('now')),
            updated_at TEXT DEFAULT (datetime('now')),
            UNIQUE(owner, name)
          )
        SQL

        @conn.execute(<<~SQL)
          CREATE TABLE IF NOT EXISTS pull_requests (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            repo_id INTEGER NOT NULL,
            number INTEGER NOT NULL,
            title TEXT NOT NULL,
            author TEXT NOT NULL,
            base_branch TEXT NOT NULL,
            head_branch TEXT NOT NULL,
            head_sha TEXT NOT NULL,
            state TEXT DEFAULT 'open',
            created_at TEXT DEFAULT (datetime('now')),
            updated_at TEXT DEFAULT (datetime('now')),
            FOREIGN KEY (repo_id) REFERENCES repositories(id),
            UNIQUE(repo_id, number)
          )
        SQL

        @conn.execute(<<~SQL)
          CREATE TABLE IF NOT EXISTS review_runs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pr_id INTEGER NOT NULL,
            status TEXT DEFAULT 'pending',
            risk_level TEXT DEFAULT 'low',
            finding_count INTEGER DEFAULT 0,
            ai_model TEXT,
            head_sha TEXT NOT NULL,
            started_at TEXT DEFAULT (datetime('now')),
            completed_at TEXT,
            FOREIGN KEY (pr_id) REFERENCES pull_requests(id)
          )
        SQL

        @conn.execute(<<~SQL)
          CREATE TABLE IF NOT EXISTS findings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            review_run_id INTEGER NOT NULL,
            severity TEXT NOT NULL,
            category TEXT DEFAULT 'bug',
            file_path TEXT NOT NULL,
            line_number INTEGER,
            title TEXT NOT NULL,
            description TEXT,
            suggestion TEXT,
            source TEXT DEFAULT 'ai',
            FOREIGN KEY (review_run_id) REFERENCES review_runs(id)
          )
        SQL

        @conn.execute(<<~SQL)
          CREATE TABLE IF NOT EXISTS cached_diffs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pr_id INTEGER NOT NULL,
            head_sha TEXT NOT NULL,
            diff_data TEXT NOT NULL,
            created_at TEXT DEFAULT (datetime('now')),
            FOREIGN KEY (pr_id) REFERENCES pull_requests(id),
            UNIQUE(pr_id, head_sha)
          )
        SQL

        @conn.execute("CREATE INDEX IF NOT EXISTS idx_findings_review_run ON findings(review_run_id)")
        @conn.execute("CREATE INDEX IF NOT EXISTS idx_findings_severity ON findings(severity)")
        @conn.execute("CREATE INDEX IF NOT EXISTS idx_pull_requests_repo ON pull_requests(repo_id)")
        @conn.execute("CREATE INDEX IF NOT EXISTS idx_review_runs_pr ON review_runs(pr_id)")
      end
    end
  end
end

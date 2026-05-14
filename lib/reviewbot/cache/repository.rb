module Reviewbot
  module Cache
    class Repository
      def initialize(db: nil)
        @db = db || Database.new.connect!
      end

      def find(id)
        row = @db.execute("SELECT * FROM repositories WHERE id = ?", [id]).first
        row ? Models::Repository.from_row(row) : nil
      end

      def find_by_owner_and_name(owner, name)
        row = @db.execute("SELECT * FROM repositories WHERE owner = ? AND name = ?", [owner, name]).first
        row ? Models::Repository.from_row(row) : nil
      end

      def find_or_create(owner:, name:, remote_url:, local_path: nil)
        repo = find_by_owner_and_name(owner, name)
        return repo if repo

        @db.execute(
          "INSERT INTO repositories (owner, name, remote_url, local_path) VALUES (?, ?, ?, ?)",
          [owner, name, remote_url, local_path]
        )
        find(@db.connection.last_insert_row_id)
      end

      def update_stack_profile(id, profile)
        @db.execute(
          "UPDATE repositories SET stack_profile = ?, updated_at = datetime('now') WHERE id = ?",
          [profile.to_hash.to_json, id]
        )
      end

      def update_local_path(id, path)
        @db.execute(
          "UPDATE repositories SET local_path = ?, updated_at = datetime('now') WHERE id = ?",
          [path, id]
        )
      end

      def all
        @db.execute("SELECT * FROM repositories ORDER BY updated_at DESC").map { |r| Models::Repository.from_row(r) }
      end
    end
  end
end

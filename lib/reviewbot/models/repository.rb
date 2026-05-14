module Reviewbot
  module Models
    class Repository
      attr_accessor :id, :owner, :name, :remote_url, :local_path, :stack_profile, :created_at, :updated_at

      def initialize(id: nil, owner:, name:, remote_url:, local_path: nil, stack_profile: nil, created_at: nil, updated_at: nil)
        @id = id
        @owner = owner
        @name = name
        @remote_url = remote_url
        @local_path = local_path
        @stack_profile = stack_profile
        @created_at = created_at
        @updated_at = updated_at
      end

      def to_hash
        {
          id: @id,
          owner: @owner,
          name: @name,
          remote_url: @remote_url,
          local_path: @local_path,
          stack_profile: @stack_profile,
          created_at: @created_at,
          updated_at: @updated_at
        }
      end

      def self.from_row(row)
        new(
          id: row["id"],
          owner: row["owner"],
          name: row["name"],
          remote_url: row["remote_url"],
          local_path: row["local_path"],
          stack_profile: row["stack_profile"],
          created_at: row["created_at"],
          updated_at: row["updated_at"]
        )
      end
    end
  end
end

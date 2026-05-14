module Reviewbot
  module Services
    class DiffExtractor
      def initialize(git_cli: nil)
        @git_cli = git_cli || Reviewbot::Git::CLI.new
      end

      def extract(repo_path:, base_branch:, head_branch: nil, head_sha: nil)
        base = base_branch
        head = head_branch || head_sha

        raw_files = @git_cli.diff_files(base, head, dir: repo_path)
        return [] if raw_files.nil? || raw_files.empty?

        full_diff = @git_cli.diff(base, head, dir: repo_path)
        parsed_diffs = parse_diff(full_diff)

        raw_files.map do |file_entry|
          path = file_entry[:path]
          diff_info = parsed_diffs[path] || { additions: 0, deletions: 0, patch: "" }

          Models::DiffFile.new(
            path: path,
            status: file_entry[:status],
            additions: diff_info[:additions],
            deletions: diff_info[:deletions],
            patch: diff_info[:patch]
          )
        end
      end

      private

      def parse_diff(diff_output)
        files = {}
        current_file = nil
        current_patch = []
        additions = 0
        deletions = 0

        diff_output.each_line do |line|
          if line.start_with?("diff --git")
            if current_file
              files[current_file] = { additions: additions, deletions: deletions, patch: current_patch.join }
            end
            current_file = line.split(%r{ b/}).last&.strip
            current_patch = [line]
            additions = 0
            deletions = 0
          elsif current_file
            current_patch << line
            if line.start_with?("+") && !line.start_with?("+++")
              additions += 1
            elsif line.start_with?("-") && !line.start_with?("---")
              deletions += 1
            end
          end
        end

        if current_file
          files[current_file] = { additions: additions, deletions: deletions, patch: current_patch.join }
        end

        files
      end
    end
  end
end

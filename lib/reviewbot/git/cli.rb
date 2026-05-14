module Reviewbot
  module Git
    class CLI
      def execute(command, dir: nil)
        dir_cmd = dir ? "cd #{dir} && " : ""
        full_cmd = "#{dir_cmd}#{command} 2>&1"
        output = `#{full_cmd}`
        unless $?.success?
          Reviewbot::Utils::Logger.warn "Command failed (exit #{$?.exitstatus}): #{command}"
          return nil
        end
        output.strip
      end

      def execute!(command, dir: nil)
        result = execute(command, dir: dir)
        raise Utils::ErrorHandler::ToolNotFoundError, "Command failed: #{command}" if result.nil?
        result
      end

      def current_branch(dir: nil)
        execute!("git rev-parse --abbrev-ref HEAD", dir: dir)
      end

      def current_sha(dir: nil)
        execute!("git rev-parse HEAD", dir: dir)
      end

      def clone(repo_url, target_dir)
        execute!("git clone #{repo_url} #{target_dir}")
      end

      def fetch(dir: nil)
        execute!("git fetch --all", dir: dir)
      end

      def diff(base, head, dir: nil)
        execute!("git diff #{base}...#{head}", dir: dir) || ""
      end

      def diff_files(base, head, dir: nil)
        output = execute!("git diff #{base}...#{head} --name-status", dir: dir)
        output.split("\n").map do |line|
          parts = line.split("\t")
          { status: parts[0], path: parts[1] }
        end
      end

      def checkout(branch, dir: nil)
        execute!("git checkout #{branch}", dir: dir)
      end

      def branch_exists?(branch, dir: nil)
        result = execute("git branch --list #{branch}", dir: dir)
        !result.nil? && !result.empty?
      end

      def repo_root(dir: nil)
        execute!("git rev-parse --show-toplevel", dir: dir)
      end
    end
  end
end

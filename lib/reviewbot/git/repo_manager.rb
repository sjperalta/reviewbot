module Reviewbot
  module Git
    class RepoManager
      def initialize(git_cli: nil)
        @git_cli = git_cli || CLI.new
      end

      def ensure_cloned(owner:, name:, workspace: nil)
        workspace ||= Config::Defaults::WORKSPACE_DIR
        repo_path = File.join(workspace, owner, name)

        if Dir.exist?(repo_path)
          Reviewbot::Utils::Logger.debug "Repository already cloned at #{repo_path}"
          @git_cli.fetch(dir: repo_path)
          return repo_path
        end

        clone_url = "https://github.com/#{owner}/#{name}.git"
        FileUtils.mkdir_p(File.dirname(repo_path))

        Reviewbot::Utils::Logger.info "Cloning #{owner}/#{name} to #{repo_path}"
        @git_cli.clone(clone_url, repo_path)
        repo_path
      end

      def repo_exists_locally?(owner, name, workspace: nil)
        workspace ||= Config::Defaults::WORKSPACE_DIR
        Dir.exist?(File.join(workspace, owner, name))
      end

      def parse_repo_full_name(full_name)
        parts = full_name.split("/")
        { owner: parts[0], name: parts[1] }
      end
    end
  end
end

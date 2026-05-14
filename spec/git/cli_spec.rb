require "spec_helper"

RSpec.describe Reviewbot::Git::CLI do
  subject(:git_cli) { described_class.new }

  describe "#execute" do
    it "executes a command and returns output" do
      result = git_cli.execute("echo hello")
      expect(result).to eq("hello")
    end

    it "returns nil for failed commands" do
      result = git_cli.execute("nonexistent_command_xyz 2>/dev/null")
      expect(result).to be_nil
    end
  end

  describe "#execute!" do
    it "raises for failed commands" do
      expect { git_cli.execute!("nonexistent_command_xyz 2>/dev/null") }
        .to raise_error(Reviewbot::Utils::ErrorHandler::ToolNotFoundError)
    end
  end
end

RSpec.describe Reviewbot::Git::BranchManager do
  subject(:manager) { described_class.new(git_cli: git_cli) }
  let(:git_cli) { instance_double(Reviewbot::Git::CLI) }

  describe "#save_current_branch" do
    it "saves and returns current branch" do
      allow(git_cli).to receive(:current_branch).with(dir: nil).and_return("main")
      expect(manager.save_current_branch).to eq("main")
    end
  end

  describe "#restore" do
    it "restores the saved branch" do
      allow(git_cli).to receive(:current_branch).with(dir: nil).and_return("feature")
      manager.save_current_branch
      expect(git_cli).to receive(:checkout).with("feature", dir: nil)
      manager.restore
    end

    it "does nothing if no branch was saved" do
      expect(git_cli).not_to receive(:checkout)
      manager.restore
    end
  end
end

RSpec.describe Reviewbot::Git::RepoManager do
  subject(:repo_manager) { described_class.new(git_cli: git_cli) }
  let(:git_cli) { instance_double(Reviewbot::Git::CLI) }

  describe "#ensure_cloned" do
    let(:workspace) { Dir.mktmpdir }

    after { FileUtils.remove_entry(workspace) }

    it "clones when repo does not exist locally" do
      expect(git_cli).to receive(:clone).with(
        "https://github.com/owner/repo.git",
        /#{workspace}\/owner\/repo/
      )
      repo_manager.ensure_cloned(owner: "owner", name: "repo", workspace: workspace)
    end

    it "fetches when repo already exists" do
      repo_path = File.join(workspace, "owner", "repo")
      FileUtils.mkdir_p(repo_path)

      expect(git_cli).to receive(:fetch).with(dir: repo_path)
      expect(git_cli).not_to receive(:clone)

      repo_manager.ensure_cloned(owner: "owner", name: "repo", workspace: workspace)
    end
  end

  describe "#parse_repo_full_name" do
    it "splits owner and name" do
      result = repo_manager.parse_repo_full_name("owner/repo")
      expect(result[:owner]).to eq("owner")
      expect(result[:name]).to eq("repo")
    end
  end
end

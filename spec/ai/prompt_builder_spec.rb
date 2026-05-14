require "spec_helper"

RSpec.describe Reviewbot::AI::PromptBuilder do
  subject(:builder) { described_class.new }

  describe "#build_system_prompt" do
    it "returns a system prompt" do
      prompt = builder.build_system_prompt
      expect(prompt[:role]).to eq("system")
      expect(prompt[:content]).to include("code reviewer")
    end
  end

  describe "#build_language_prompt" do
    it "generates Rails-specific prompt" do
      profile = Reviewbot::Models::RepoProfile.new(primary_stack: "rails", stacks: ["rails"])
      prompt = builder.build_language_prompt(profile)
      expect(prompt[:role]).to eq("system")
      expect(prompt[:content]).to include("N+1")
    end

    it "generates Go-specific prompt" do
      profile = Reviewbot::Models::RepoProfile.new(primary_stack: "go", stacks: ["go"])
      prompt = builder.build_language_prompt(profile)
      expect(prompt[:content]).to include("Goroutine")
    end

    it "generates Flutter-specific prompt" do
      profile = Reviewbot::Models::RepoProfile.new(primary_stack: "flutter", stacks: ["flutter"])
      prompt = builder.build_language_prompt(profile)
      expect(prompt[:content]).to include("Widget")
    end

    it "generates general prompt for unknown stack" do
      profile = Reviewbot::Models::RepoProfile.new(primary_stack: "unknown", stacks: [])
      prompt = builder.build_language_prompt(profile)
      expect(prompt[:content].downcase).to include("correctness")
    end
  end

  describe "#build_repository_prompt" do
    it "returns nil when no config exists" do
      repo_config = instance_double(Reviewbot::Config::RepositoryConfig, exists?: false)
      expect(builder.build_repository_prompt(repo_config)).to be_nil
    end

    it "returns prompt with rules when config exists" do
      repo_config = instance_double(Reviewbot::Config::RepositoryConfig,
        exists?: true,
        rules: { "require_specs" => true, "avoid_fat_controllers" => true })
      prompt = builder.build_repository_prompt(repo_config)
      expect(prompt).not_to be_nil
      expect(prompt[:content]).to include("require_specs")
    end
  end

  describe "#build_pr_context_prompt" do
    it "builds context with PR data and diffs" do
      pr_data = { title: "Fix bug", author: "dev", number: 1 }
      diff_files = [
        Reviewbot::Models::DiffFile.new(
          path: "test.rb", status: "modified",
          additions: 5, deletions: 2,
          patch: "diff content", category: "source"
        )
      ]

      prompt = builder.build_pr_context_prompt(pr_data: pr_data, diff_files: diff_files, analysis: nil)
      expect(prompt[:role]).to eq("user")
      expect(prompt[:content]).to include("Fix bug")
      expect(prompt[:content]).to include("test.rb")
    end
  end
end

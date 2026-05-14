require "spec_helper"

RSpec.describe Reviewbot::Analyzers::RubocopRunner do
  subject(:runner) { described_class.new }

  describe "#run" do
    it "returns result with error when rubocop not installed" do
      allow(runner).to receive(:tool_installed?).and_return(false)
      result = runner.run(dir: "/tmp")
      expect(result.success?).to be false
      expect(result.errors).to include(a_string_matching(/not installed/))
    end
  end
end

RSpec.describe Reviewbot::Analyzers::BrakemanRunner do
  subject(:runner) { described_class.new }

  describe "#run" do
    it "skips when brakeman not installed" do
      allow(runner).to receive(:tool_installed?).and_return(false)
      result = runner.run(dir: "/tmp")
      expect(result.errors).to include(a_string_matching(/not installed/))
    end
  end
end

RSpec.describe Reviewbot::Analyzers::ESLintRunner do
  subject(:runner) { described_class.new }

  describe "#run" do
    it "skips when eslint not installed" do
      allow(runner).to receive(:tool_installed?).and_return(false)
      result = runner.run(dir: "/tmp")
      expect(result.errors).to include(a_string_matching(/not installed/))
    end
  end
end

RSpec.describe Reviewbot::Analyzers::GolangciLintRunner do
  subject(:runner) { described_class.new }

  describe "#run" do
    it "skips when golangci-lint not installed" do
      allow(runner).to receive(:tool_installed?).and_return(false)
      result = runner.run(dir: "/tmp")
      expect(result.errors).to include(a_string_matching(/not installed/))
    end
  end
end

RSpec.describe Reviewbot::Analyzers::Orchestrator do
  subject(:orchestrator) { described_class.new }

  describe "#analyze" do
    it "returns merged result for a profile" do
      profile = Reviewbot::Models::RepoProfile.new(stacks: ["ruby"], primary_stack: "ruby")

      # Mock all runners to return empty results quickly
      allow_any_instance_of(Reviewbot::Analyzers::RubocopRunner).to receive(:run)
        .and_return(Reviewbot::Models::AnalysisResult.new(tool: "rubocop"))
      allow_any_instance_of(Reviewbot::Analyzers::ReekRunner).to receive(:run)
        .and_return(Reviewbot::Models::AnalysisResult.new(tool: "reek"))

      result = orchestrator.analyze(profile, dir: "/tmp")
      expect(result.tool).to eq("combined")
    end
  end
end

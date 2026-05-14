require "spec_helper"

RSpec.describe Reviewbot::Services::PipelineOrchestrator do
  subject(:orchestrator) { described_class.new }

  describe "#run" do
    it "executes phases in order" do
      # Stub git commands to prevent real execution
      allow_any_instance_of(Reviewbot::Git::CLI).to receive(:diff_files).and_return([])
      allow_any_instance_of(Reviewbot::Git::CLI).to receive(:diff).and_return("")
      allow_any_instance_of(Reviewbot::Services::DiffExtractor).to receive(:extract).and_return([])
      allow_any_instance_of(Reviewbot::Analyzers::Orchestrator).to receive(:analyze)
        .and_return(Reviewbot::Models::AnalysisResult.new(tool: "combined"))

      pr_data = {
        number: 1,
        title: "Test",
        repo_path: Dir.pwd,
        base_branch: "main",
        head_branch: "feature"
      }

      options = Reviewbot::Config::Options.new(cli_options: {}, loader: Reviewbot::Config::Loader.new)

      phases = []
      orchestrator.run(pr_data: pr_data, options: options) do |phase, status|
        phases << { phase: phase, status: status }
      end

      expect(phases.map { |p| p[:phase] }).to include("detecting", "diffing", "analyzing", "reviewing")
    end
  end
end

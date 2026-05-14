require "spec_helper"

RSpec.describe Reviewbot::CLI::Base do
  describe "commands" do
    it "defines prs command" do
      expect(Reviewbot::CLI::Base.commands).to include("prs")
    end

    it "defines review command" do
      expect(Reviewbot::CLI::Base.commands).to include("review")
    end

    it "defines publish command" do
      expect(Reviewbot::CLI::Base.commands).to include("publish")
    end

    it "defines export command" do
      expect(Reviewbot::CLI::Base.commands).to include("export")
    end

    it "defines cache:clear command" do
      expect(Reviewbot::CLI::Base.commands).to include("cache_clear")
    end

    it "defines version command" do
      expect(Reviewbot::CLI::Base.commands).to include("version")
    end
  end

  describe "global options" do
    it "has verbose option" do
      opts = Reviewbot::CLI::Base.class_options
      expect(opts).to have_key(:verbose)
    end

    it "has config option" do
      opts = Reviewbot::CLI::Base.class_options
      expect(opts).to have_key(:config)
    end
  end
end

RSpec.describe Reviewbot::CLI::PRS do
  subject(:command) { described_class.new }

  let(:pr_lister) { instance_double(Reviewbot::GitHub::PRLister) }
  let(:pr_table) { instance_double(Reviewbot::Formatters::Terminal::PRTable) }
  let(:display) { instance_double(Reviewbot::Formatters::Terminal::Display) }

  before do
    allow(display).to receive(:header)
    allow(pr_table).to receive(:render)
  end

  describe "#run" do
    it "lists assigned PRs" do
      prs = [{ "number" => 1, "title" => "Test", "repository" => { "nameWithOwner" => "owner/repo" }, "author" => { "login" => "dev" } }]
      allow(pr_lister).to receive(:list_assigned).and_return(prs)

      cmd = described_class.new(pr_lister: pr_lister, pr_table: pr_table, display: display)
      expect(cmd.run).to eq(prs)
    end
  end
end

RSpec.describe Reviewbot::CLI::Cache do
  subject(:command) { described_class.new(display: display) }
  let(:display) { instance_double(Reviewbot::Formatters::Terminal::Display) }

  before do
    allow(display).to receive(:header)
    allow(display).to receive(:success)
  end

  describe "#clear" do
    it "clears cache" do
      expect_any_instance_of(Reviewbot::Cache::Manager).to receive(:clear_caches!)
      command.clear
    end
  end
end

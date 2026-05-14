require "spec_helper"

RSpec.describe Reviewbot::Config::RepositoryConfig do
  describe "with a valid .reviewbot.yml" do
    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(".reviewbot.yml").and_return(true)
      allow(Psych).to receive(:safe_load_file).and_return({
        "stack" => ["rails", "react"],
        "rules" => { "require_specs" => true },
        "ignore" => ["db/schema.rb", "yarn.lock"]
      })
    end

    subject(:config) { described_class.new }

    it "parses stack from config" do
      expect(config.stack).to eq(["rails", "react"])
    end

    it "parses rules from config" do
      expect(config.rules).to eq({ "require_specs" => true })
    end

    it "parses ignore patterns" do
      expect(config.ignore_patterns).to eq(["db/schema.rb", "yarn.lock"])
    end

    it "detects stack presence" do
      expect(config.stack_detected?).to be true
    end
  end

  describe "with no config file" do
    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(".reviewbot.yml").and_return(false)
      allow(File).to receive(:exist?).with(".reviewbot.yaml").and_return(false)
    end

    subject(:config) { described_class.new }

    it "has empty stack" do
      expect(config.stack).to eq([])
    end

    it "has empty rules" do
      expect(config.rules).to eq({})
    end

    it "reports not existing" do
      expect(config.exists?).to be false
    end
  end
end

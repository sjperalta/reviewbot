require "spec_helper"

RSpec.describe Reviewbot::Models::RepoProfile do
  describe "detection helpers" do
    it "detects Ruby" do
      profile = described_class.new(stacks: ["ruby"], primary_stack: "ruby")
      expect(profile.ruby?).to be true
      expect(profile.node?).to be false
    end

    it "detects Rails" do
      profile = described_class.new(stacks: ["rails", "ruby"], primary_stack: "rails")
      expect(profile.rails?).to be true
      expect(profile.ruby?).to be true
    end

    it "detects TypeScript" do
      profile = described_class.new(stacks: ["typescript"], has_typescript: true)
      expect(profile.typescript?).to be true
      expect(profile.node?).to be true
    end

    it "detects React" do
      profile = described_class.new(stacks: ["react"], has_react: true)
      expect(profile.react?).to be true
    end

    it "detects Flutter" do
      profile = described_class.new(stacks: ["flutter", "dart"], primary_stack: "flutter")
      expect(profile.flutter?).to be true
      expect(profile.dart?).to be true
    end

    it "detects Go" do
      profile = described_class.new(stacks: ["go"], primary_stack: "go")
      expect(profile.go?).to be true
    end
  end
end

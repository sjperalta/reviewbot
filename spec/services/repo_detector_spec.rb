require "spec_helper"

RSpec.describe Reviewbot::Services::RepoDetector do
  subject(:detector) { described_class.new }

  describe "#detect_from_files" do
    it "detects Rails from Gemfile and config/application.rb" do
      profile = detector.detect_from_files(["Gemfile", "config/application.rb"])
      expect(profile.rails?).to be true
      expect(profile.primary_stack).to eq("rails")
    end

    it "detects Ruby from Gemfile alone" do
      profile = detector.detect_from_files(["Gemfile"])
      expect(profile.ruby?).to be true
    end

    it "detects JavaScript/TypeScript from tsconfig.json and package.json" do
      profile = detector.detect_from_files(["package.json", "tsconfig.json"])
      expect(profile.typescript?).to be true
    end

    it "detects Go from go.mod" do
      profile = detector.detect_from_files(["go.mod"])
      expect(profile.go?).to be true
    end

    it "detects Flutter from pubspec.yaml" do
      profile = detector.detect_from_files(["pubspec.yaml"])
      expect(profile.flutter?).to be true
    end

    it "returns unknown profile for no recognizable files" do
      profile = detector.detect_from_files(["readme.md"])
      expect(profile.primary_stack).to eq("unknown")
    end
  end
end

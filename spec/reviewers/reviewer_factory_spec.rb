require "spec_helper"

RSpec.describe Reviewbot::Reviewers::ReviewerFactory do
  describe ".for_profile" do
    it "returns Rails reviewer for Rails profile" do
      profile = Reviewbot::Models::RepoProfile.new(stacks: ["rails", "ruby"], primary_stack: "rails")
      reviewers = described_class.for_profile(profile)
      expect(reviewers.map(&:name)).to include("rails")
    end

    it "returns Go reviewer for Go profile" do
      profile = Reviewbot::Models::RepoProfile.new(stacks: ["go"], primary_stack: "go")
      reviewers = described_class.for_profile(profile)
      expect(reviewers.map(&:name)).to include("go")
    end

    it "returns multiple reviewers for React TypeScript profile" do
      profile = Reviewbot::Models::RepoProfile.new(
        stacks: ["typescript", "javascript", "react"],
        primary_stack: "react",
        has_react: true,
        has_typescript: true
      )
      reviewers = described_class.for_profile(profile)
      expect(reviewers.map(&:name)).to include("react", "typescript")
    end
  end

  describe ".analyzers_for_profile" do
    it "returns rubocop and brakeman for Rails" do
      profile = Reviewbot::Models::RepoProfile.new(stacks: ["rails", "ruby"], primary_stack: "rails")
      analyzers = described_class.analyzers_for_profile(profile)
      expect(analyzers).to include(:rubocop, :brakeman)
    end
  end
end

require "spec_helper"

RSpec.describe Reviewbot::Models::Finding do
  subject(:finding) do
    described_class.new(
      review_run_id: 1,
      severity: "high",
      file_path: "app/models/user.rb",
      title: "Test finding",
      description: "Description",
      suggestion: "Fix it"
    )
  end

  describe "#critical?" do
    it "returns false for high severity" do
      expect(finding).not_to be_critical
    end

    it "returns true for critical severity" do
      finding.severity = "critical"
      expect(finding).to be_critical
    end
  end

  describe "#to_hash" do
    it "includes all fields" do
      hash = finding.to_hash
      expect(hash[:severity]).to eq("high")
      expect(hash[:file_path]).to eq("app/models/user.rb")
    end
  end
end

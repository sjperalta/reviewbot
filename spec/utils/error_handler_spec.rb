require "spec_helper"

RSpec.describe Reviewbot::Utils::ErrorHandler do
  describe ".handle" do
    it "handles ToolNotFoundError gracefully" do
      result = described_class.handle(
        described_class::ToolNotFoundError.new("rubocop not found"),
        context: "test"
      )
      expect(result).to be_nil
    end

    it "handles ConfigError gracefully" do
      result = described_class.handle(
        described_class::ConfigError.new("Missing GITHUB_TOKEN"),
        context: "config"
      )
      expect(result).to be_nil
    end

    it "handles APIError gracefully" do
      result = described_class.handle(
        described_class::APIError.new("API returned 500"),
        context: "api"
      )
      expect(result).to be_nil
    end
  end

  describe ".severity_from_string" do
    it "maps string to severity symbol" do
      expect(described_class.severity_from_string("HIGH")).to eq(:high)
      expect(described_class.severity_from_string("CRITICAL")).to eq(:critical)
      expect(described_class.severity_from_string("unknown")).to eq(:low)
    end
  end
end

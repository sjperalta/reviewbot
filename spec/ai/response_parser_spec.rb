require "spec_helper"

RSpec.describe Reviewbot::AI::ResponseParser do
  subject(:parser) { described_class.new }

  describe "#parse" do
    it "parses valid JSON response" do
      response = { content: <<~JSON.strip }
        {
          "summary": "Good PR",
          "risk_level": "low",
          "findings": [
            {
              "severity": "medium",
              "file": "app/models/user.rb",
              "line": 42,
              "title": "Test issue",
              "description": "Description",
              "suggestion": "Fix"
            }
          ],
          "missing_tests": [],
          "architecture_notes": [],
          "security_notes": []
        }
      JSON

      result = parser.parse(response)
      expect(result[:summary]).to be_a(Hash)
      expect(result[:summary][:text]).to eq("Good PR")
      expect(result[:risk_level]).to eq("low")
      expect(result[:findings].size).to eq(1)
      expect(result[:findings].first[:file]).to eq("app/models/user.rb")
    end

    it "extracts JSON from code block" do
      response = { content: <<~MARKDOWN }
        Here is my review:

        ```json
        {
          "summary": "Looks good",
          "risk_level": "low",
          "findings": [],
          "missing_tests": [],
          "architecture_notes": [],
          "security_notes": []
        }
        ```
      MARKDOWN

      result = parser.parse(response)
      expect(result[:summary][:text]).to eq("Looks good")
      expect(result[:risk_level]).to eq("low")
    end

    it "falls back to text parsing for malformed JSON" do
      response = { content: "Risk level: high\nSeverity: critical\nFile: test.rb\nTitle: Issue" }
      result = parser.parse(response)
      expect(result[:risk_level]).to eq("high")
    end

    it "re-normalizes cached-style payloads with a string summary" do
      raw = {
        summary: "Cached string summary",
        risk_level: "high",
        findings: []
      }
      fixed = parser.validate_parsed(raw)
      expect(fixed[:summary]).to be_a(Hash)
      expect(fixed[:summary][:text]).to eq("Cached string summary")
    end
  end
end

require "spec_helper"

RSpec.describe Reviewbot::Formatters::Markdown::Report do
  subject(:report) { described_class.new }

  let(:pr_data) do
    { number: 123, title: "Test PR", author: "testuser" }
  end

  let(:review_result) do
    {
      summary: { text: "Good changes overall" },
      risk_level: "medium",
      findings: [
        {
          severity: "high",
          file: "app/models/user.rb",
          line: 42,
          title: "Security issue",
          description: "SQL injection risk",
          suggestion: "Use parameterized queries"
        },
        {
          severity: "low",
          file: "app/controllers/users_controller.rb",
          line: 10,
          title: "Style nit",
          description: "Minor style issue",
          suggestion: nil
        }
      ],
      missing_tests: [{ file: "app/services/payment_service.rb", reason: "No test file found" }],
      architecture_notes: ["Consider extracting payment logic into service object"],
      security_notes: ["SQL injection in User queries"]
    }
  end

  describe "#generate" do
    it "includes PR summary section" do
      result = report.generate(pr_data: pr_data, review_result: review_result)
      expect(result).to include("Review Summary")
      expect(result).to include("#123")
      expect(result).to include("Test PR")
    end

    it "includes findings grouped by severity" do
      result = report.generate(pr_data: pr_data, review_result: review_result)
      expect(result).to include("High")
      expect(result).to include("Security issue")
      expect(result).to include("Low")
    end

    it "includes missing tests section" do
      result = report.generate(pr_data: pr_data, review_result: review_result)
      expect(result).to include("Missing Tests")
      expect(result).to include("payment_service")
    end

    it "includes architecture notes" do
      result = report.generate(pr_data: pr_data, review_result: review_result)
      expect(result).to include("Architecture Notes")
    end

    it "includes security notes" do
      result = report.generate(pr_data: pr_data, review_result: review_result)
      expect(result).to include("Security Notes")
    end
  end

  describe "#generate_to_file" do
    it "writes to file" do
      dir = Dir.mktmpdir
      path = report.generate_to_file(pr_data: pr_data, review_result: review_result, output_dir: dir)
      expect(File.exist?(path)).to be true
      expect(File.read(path)).to include("Review Summary")
      FileUtils.remove_entry(dir)
    end
  end
end

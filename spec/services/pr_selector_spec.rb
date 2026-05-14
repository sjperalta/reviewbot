require "spec_helper"

RSpec.describe Reviewbot::Services::PRSelector do
  let(:pr_lister) { instance_double(Reviewbot::GitHub::PRLister) }
  subject(:selector) { described_class.new(pr_lister: pr_lister) }

  let(:sample_prs) do
    [
      {
        "number" => 16,
        "title" => "Example",
        "url" => "https://github.com/org/repo/pull/16",
        "baseRefName" => "main",
        "headRefName" => "feature"
      }
    ]
  end

  before do
    allow(pr_lister).to receive(:list_assigned).and_return(sample_prs)
  end

  describe "#select_by_number" do
    it "finds PR when CLI passes a string and gh JSON has an integer number" do
      expect(selector.select_by_number("16")).to eq(sample_prs.first)
    end

    it "finds PR when given an integer" do
      expect(selector.select_by_number(16)).to eq(sample_prs.first)
    end

    it "returns nil when no matching PR" do
      expect(selector.select_by_number("99")).to be_nil
    end

    it "returns nil for non-numeric input" do
      expect(selector.select_by_number("abc")).to be_nil
    end
  end
end

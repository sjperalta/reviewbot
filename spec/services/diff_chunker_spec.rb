require "spec_helper"

RSpec.describe Reviewbot::Services::DiffChunker do
  subject(:chunker) { described_class.new }

  describe "#chunk" do
    it "returns empty array for empty input" do
      expect(chunker.chunk([])).to eq([])
    end

    it "groups files into chunks" do
      files = [
        Reviewbot::Models::DiffFile.new(path: "app/models/user.rb", status: "modified", additions: 10, deletions: 2, patch: "changes here", category: "source"),
        Reviewbot::Models::DiffFile.new(path: "spec/models/user_spec.rb", status: "modified", additions: 5, deletions: 1, patch: "test changes", category: "test")
      ]

      chunks = chunker.chunk(files)
      expect(chunks.size).to be >= 1
      expect(chunks.first.files.map(&:path)).to include("app/models/user.rb")
    end
  end
end

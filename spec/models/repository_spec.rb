require "spec_helper"

RSpec.describe Reviewbot::Models::Repository do
  subject(:repo) do
    described_class.new(
      owner: "test-owner",
      name: "test-repo",
      remote_url: "https://github.com/test-owner/test-repo"
    )
  end

  describe "#to_hash" do
    it "includes all fields" do
      hash = repo.to_hash
      expect(hash[:owner]).to eq("test-owner")
      expect(hash[:name]).to eq("test-repo")
      expect(hash[:remote_url]).to eq("https://github.com/test-owner/test-repo")
    end
  end

  describe ".from_row" do
    it "creates instance from database row" do
      row = {
        "id" => 1,
        "owner" => "owner",
        "name" => "name",
        "remote_url" => "url",
        "local_path" => "/path",
        "stack_profile" => '{"stacks":["ruby"]}',
        "created_at" => "2024-01-01",
        "updated_at" => "2024-01-01"
      }
      instance = described_class.from_row(row)
      expect(instance.owner).to eq("owner")
      expect(instance.name).to eq("name")
    end
  end
end

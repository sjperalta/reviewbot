require "spec_helper"

RSpec.describe Reviewbot::GitHub::PRFetcher do
  subject(:fetcher) { described_class.new(client: client) }

  let(:client) { instance_double(Reviewbot::GitHub::Client) }
  let(:pr_response) do
    {
      number: 1,
      title: "Test PR",
      body: "Description",
      user: { login: "author" },
      state: "open",
      labels: [{ name: "bug" }],
      base: {
        ref: "main",
        sha: "base-sha",
        repo: { full_name: "owner/repo" }
      },
      head: { ref: "feature", sha: "head-sha" },
      created_at: Time.now,
      updated_at: Time.now
    }
  end

  let(:files_response) do
    [{ filename: "test.rb", status: "modified", additions: 10, deletions: 2, patch: "diff" }]
  end

  let(:commits_response) do
    [{ sha: "abc123", commit: { message: "Fix bug", author: { name: "dev", date: Time.now } } }]
  end

  before do
    allow(client).to receive(:pull_request).with("owner/repo", 1).and_return(pr_response)
    allow(client).to receive(:pull_request_files).with("owner/repo", 1).and_return(files_response)
    allow(client).to receive(:pull_request_commits).with("owner/repo", 1).and_return(commits_response)
    allow(client).to receive(:pull_request_labels).with("owner/repo", 1).and_return(["bug"])
  end

  describe "#fetch" do
    it "returns complete PR data" do
      result = fetcher.fetch("owner/repo", 1)
      expect(result[:number]).to eq(1)
      expect(result[:title]).to eq("Test PR")
      expect(result[:author]).to eq("author")
      expect(result[:files].size).to eq(1)
      expect(result[:commits].size).to eq(1)
    end
  end

  describe "#fetch_metadata" do
    it "returns PR metadata" do
      result = fetcher.fetch_metadata("owner/repo", 1)
      expect(result[:number]).to eq(1)
      expect(result[:labels]).to eq(["bug"])
      expect(result[:head_sha]).to eq("head-sha")
    end
  end
end

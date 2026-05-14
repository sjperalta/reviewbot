require "spec_helper"

RSpec.describe Reviewbot::GitHub::Client do
  let(:octokit_double) { instance_double(Octokit::Client) }

  before do
    allow(Octokit::Client).to receive(:new).and_return(octokit_double)
  end

  describe "#initialize" do
    it "creates an Octokit client with token" do
      expect(Octokit::Client).to receive(:new).with(access_token: "test-token", auto_paginate: true).and_return(octokit_double)
      client = described_class.new(token: "test-token")
      expect(client.octokit).to eq(octokit_double)
    end
  end

  describe "#repository" do
    it "returns repository data" do
      allow(octokit_double).to receive(:repository).with("owner/repo").and_return({ id: 1, full_name: "owner/repo" })
      client = described_class.new(token: "test-token")
      expect(client.repository("owner/repo")).to eq({ id: 1, full_name: "owner/repo" })
    end

    it "raises on not found" do
      allow(octokit_double).to receive(:repository).with("owner/repo").and_raise(Octokit::NotFound)
      client = described_class.new(token: "test-token")
      expect { client.repository("owner/repo") }.to raise_error(Reviewbot::Utils::ErrorHandler::APIError)
    end
  end

  describe "#pull_request" do
    it "fetches PR data" do
      allow(octokit_double).to receive(:pull_request).with("owner/repo", 1).and_return({ number: 1, title: "Test" })
      client = described_class.new(token: "test-token")
      expect(client.pull_request("owner/repo", 1)).to eq({ number: 1, title: "Test" })
    end
  end

  describe "#pull_request_files" do
    it "fetches PR files" do
      expect(octokit_double).to receive(:pull_request_files).with("owner/repo", 1).and_return([])
      client = described_class.new(token: "test-token")
      client.pull_request_files("owner/repo", 1)
    end
  end

  describe "#create_pull_request_review" do
    it "submits a review" do
      expect(octokit_double).to receive(:create_pull_request_review)
        .with("owner/repo", 1, { body: "test", comments: [], event: "COMMENT" })
      client = described_class.new(token: "test-token")
      client.create_pull_request_review("owner/repo", 1, body: "test", comments: [])
    end

    it "includes commit_id in the options hash when given" do
      expect(octokit_double).to receive(:create_pull_request_review)
        .with("owner/repo", 1, { body: "test", comments: [], event: "COMMENT", commit_id: "abc123" })
      client = described_class.new(token: "test-token")
      client.create_pull_request_review("owner/repo", 1, body: "test", comments: [], commit_id: "abc123")
    end
  end

  describe "#user" do
    it "returns current user" do
      allow(octokit_double).to receive(:user).and_return({ login: "testuser" })
      client = described_class.new(token: "test-token")
      expect(client.user).to eq({ login: "testuser" })
    end
  end
end

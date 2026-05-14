module Reviewbot
  module GitHub
    class Client
      attr_reader :octokit

      def initialize(token: nil)
        @token = token || ENV["GITHUB_TOKEN"] || gh_cli_token
        @octokit = Octokit::Client.new(access_token: @token, auto_paginate: true)
      end

      private

      def gh_cli_token
        token = `gh auth token 2>/dev/null`.strip
        token.empty? ? nil : token
      end

      public

      def repository(full_name)
        @octokit.repository(full_name)
      rescue Octokit::NotFound
        raise Utils::ErrorHandler::APIError, "Repository not found: #{full_name}"
      rescue Octokit::Unauthorized
        raise Utils::ErrorHandler::APIError, "GitHub authentication failed. Check GITHUB_TOKEN"
      end

      def pull_request(repo, number)
        @octokit.pull_request(repo, number)
      rescue Octokit::NotFound
        raise Utils::ErrorHandler::APIError, "PR ##{number} not found in #{repo}"
      end

      def pull_request_files(repo, number)
        @octokit.pull_request_files(repo, number)
      end

      def pull_request_commits(repo, number)
        @octokit.pull_request_commits(repo, number)
      end

      def pull_request_labels(repo, number)
        pr = pull_request(repo, number)
        pr[:labels]&.map { |l| l[:name] } || []
      end

      def create_pull_request_review(repo, number, body:, comments: [], event: "COMMENT", commit_id: nil)
        opts = { body: body, comments: comments, event: event }
        opts[:commit_id] = commit_id if commit_id
        @octokit.create_pull_request_review(repo, number, opts)
      rescue Octokit::UnprocessableEntity => e
        raise Utils::ErrorHandler::APIError, "Failed to publish review: #{e.message}"
      rescue Octokit::Unauthorized
        raise Utils::ErrorHandler::APIError, "GitHub authentication failed. Ensure GITHUB_TOKEN has repo scope and is valid."
      end

      def pull_requests(repo, state: "open")
        @octokit.pull_requests(repo, state: state)
      end

      def compare(repo, base, head)
        @octokit.compare(repo, base, head)
      end

      def user
        @octokit.user
      end
    end
  end
end

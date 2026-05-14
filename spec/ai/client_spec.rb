require "spec_helper"

RSpec.describe Reviewbot::AI::Client do
  subject(:client) { described_class.new(api_key: "test-key") }

  describe "#available?" do
    it "returns true with API key" do
      expect(client.available?).to be true
    end
  end

  describe "#chat" do
    let(:messages) { [{ role: "user", content: "Hello" }] }
    let(:success_response) do
      instance_double(Faraday::Response,
        success?: true,
        status: 200,
        body: {
          choices: [
            {
              message: { content: "Hi there" },
              finish_reason: "stop"
            }
          ],
          model: "deepseek-chat",
          usage: {
            prompt_tokens: 10,
            completion_tokens: 5,
            total_tokens: 15
          }
        }.to_json)
    end

    it "sends a chat request and parses response" do
      allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(success_response)
      result = client.chat(messages)
      expect(result[:content]).to eq("Hi there")
      expect(result[:model]).to eq("deepseek-chat")
    end

    it "raises on API error" do
      error_response = instance_double(Faraday::Response, success?: false, status: 500, body: "Error")
      allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(error_response)
      expect { client.chat(messages) }.to raise_error(Reviewbot::Utils::ErrorHandler::APIError)
    end

    it "raises on timeout" do
      allow_any_instance_of(Faraday::Connection).to receive(:post).and_raise(Faraday::TimeoutError)
      expect { client.chat(messages) }.to raise_error(Reviewbot::Utils::ErrorHandler::APIError)
    end
  end
end

RSpec.describe Reviewbot::AI::RetryHandler do
  subject(:handler) { described_class.new(max_retries: 2, delays: [0.01, 0.02]) }

  describe "#with_retry" do
    it "succeeds on first attempt" do
      result = handler.with_retry { |attempt| "success" }
      expect(result).to eq("success")
    end

    it "retries on failure then succeeds" do
      calls = 0
      result = handler.with_retry do |attempt|
        calls += 1
        raise Reviewbot::Utils::ErrorHandler::NetworkError, "timeout" if calls < 2
        "ok"
      end
      expect(result).to eq("ok")
      expect(calls).to eq(2)
    end

    it "raises after all retries exhausted" do
      expect {
        handler.with_retry { |_| raise Reviewbot::Utils::ErrorHandler::APIError, "fail" }
      }.to raise_error(Reviewbot::Utils::ErrorHandler::APIError)
    end
  end
end

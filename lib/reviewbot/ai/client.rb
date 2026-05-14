module Reviewbot
  module AI
    class Client
      def initialize(api_key: nil, model: nil, timeout: nil)
        @api_key = api_key || ENV["DEEPSEEK_API_KEY"]
        @model = model || Config::Defaults::AI_MODEL
        @api_url = Config::Defaults::AI_API_URL
        @timeout = timeout || Config::Defaults::API_TIMEOUT
        @conn = build_connection
      end

      def chat(messages, temperature: 0.3, max_tokens: 4096)
        response = @conn.post(@api_url) do |req|
          req.headers["Content-Type"] = "application/json"
          req.headers["Authorization"] = "Bearer #{@api_key}"
          req.body = {
            model: @model,
            messages: messages,
            temperature: temperature,
            max_tokens: max_tokens
          }.to_json
        end

        parse_response(response)
      rescue Faraday::TimeoutError
        raise Utils::ErrorHandler::APIError, "DeepSeek API timeout after #{@timeout}s"
      rescue Faraday::ConnectionFailed => e
        raise Utils::ErrorHandler::NetworkError, "Failed to connect to DeepSeek API: #{e.message}"
      rescue => e
        raise Utils::ErrorHandler::APIError, "DeepSeek API error: #{e.message}"
      end

      def available?
        !@api_key.nil? && !@api_key.empty?
      end

      private

      def build_connection
        Faraday.new do |f|
          f.request :retry, max: 0
          f.options.timeout = @timeout
          f.options.open_timeout = 10
          f.adapter Faraday.default_adapter
        end
      end

      def parse_response(response)
        unless response.success?
          raise Utils::ErrorHandler::APIError, "DeepSeek API returned #{response.status}: #{response.body[0..200]}"
        end

        body = JSON.parse(response.body)
        choice = body.dig("choices", 0)

        unless choice
          raise Utils::ErrorHandler::APIError, "DeepSeek API returned unexpected format: no choices"
        end

        content = choice.dig("message", "content") || ""
        usage = body["usage"] || {}

        {
          content: content,
          model: body["model"],
          usage: {
            prompt_tokens: usage["prompt_tokens"],
            completion_tokens: usage["completion_tokens"],
            total_tokens: usage["total_tokens"]
          },
          finish_reason: choice.dig("finish_reason")
        }
      rescue JSON::ParserError => e
        raise Utils::ErrorHandler::APIError, "Failed to parse DeepSeek response: #{e.message}"
      end
    end
  end
end

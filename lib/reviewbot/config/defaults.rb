module Reviewbot
  module Config
    module Defaults
      BASE_BRANCH = "main"
      OUTPUT_DIR = "reviews"
      WORKSPACE_DIR = File.expand_path("~/.reviewbot/workspace")
      DB_PATH = File.expand_path("~/.reviewbot/reviewbot.db")
      API_TIMEOUT = 60
      MAX_RETRIES = 3
      RETRY_DELAYS = [1, 2, 4].freeze
      TOKEN_LIMIT = 32_000
      AI_MODEL = "deepseek-chat"
      AI_API_URL = "https://api.deepseek.com/v1/chat/completions"
    end
  end
end

module Reviewbot
  module CLI
    class Cache
      def initialize(display: nil)
        @display = display || Reviewbot::Formatters::Terminal::Display.new
      end

      def clear
        @display.header("Clearing Cache")

        manager = Reviewbot::Cache::Manager.new
        manager.clear_caches!
        @display.success("Cache cleared successfully.")
      end
    end
  end
end

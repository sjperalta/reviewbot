module Reviewbot
  module Formatters
    module Terminal
      class Display
        def initialize
          @pastel = Pastel.new
        end

        def header(text)
          puts "\n#{@pastel.cyan.bold(text)}"
          puts @pastel.cyan("=" * text.length)
        end

        def info(text)
          puts @pastel.blue("ℹ #{text}")
        end

        def success(text)
          puts @pastel.green("✓ #{text}")
        end

        def warning(text)
          puts @pastel.yellow("⚠ #{text}")
        end

        def error(text)
          puts @pastel.red("✗ #{text}")
        end

        def severity_label(severity)
          case severity
          when "critical" then @pastel.magenta.bold("CRITICAL")
          when "high" then @pastel.red.bold("HIGH")
          when "medium" then @pastel.yellow("MEDIUM")
          when "low" then @pastel.green("LOW")
          else severity
          end
        end

        def divider
          puts @pastel.dim("─" * 60)
        end

        def blank_line
          puts ""
        end
      end
    end
  end
end

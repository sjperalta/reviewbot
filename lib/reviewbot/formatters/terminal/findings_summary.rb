module Reviewbot
  module Formatters
    module Terminal
      class FindingsSummary
        def initialize
          @pastel = Pastel.new
          @display = Display.new
        end

        def render(review_result)
          return @display.warning("No review results to display.") unless review_result

          findings = review_result[:findings] || []
          @display.header("Review Results")

          @display.info("Risk Level: #{review_result[:risk_level]&.upcase}")
          @display.info("Total findings: #{findings.size}")

          severity_counts = findings.group_by { |f| f[:severity] }.transform_values(&:size)
          %w[critical high medium low].each do |sev|
            count = severity_counts[sev] || 0
            next if count == 0
            label = @display.severity_label(sev)
            puts "  #{label}: #{count}"
          end

          if findings.any?
            @display.blank_line
            @display.divider
            @display.header("Findings")

            findings.each do |f|
              file_info = f[:file]
              file_info += ":#{f[:line]}" if f[:line]

              puts "  #{@display.severity_label(f[:severity])} | #{file_info}"
              puts "  #{@pastel.bold(f[:title])}"
              puts "  #{f[:description]}" if f[:description] && !f[:description].empty?
              @display.divider
            end
          end
        end
      end
    end
  end
end

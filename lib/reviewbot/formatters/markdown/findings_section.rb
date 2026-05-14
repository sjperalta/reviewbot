module Reviewbot
  module Formatters
    module Markdown
      class FindingsSection
        def generate(findings)
          return nil if findings.nil? || findings.empty?

          content = "## Findings\n\n"

          %w[critical high medium low].each do |severity|
            grouped = findings.select { |f| f[:severity] == severity }
            next if grouped.empty?

            content += "### #{severity.capitalize}\n\n"
            grouped.each do |f|
              file_info = f[:file]
              file_info += ":#{f[:line]}" if f[:line]
              content += "- **#{f[:title]}** (#{file_info})\n"
              content += "  - #{f[:description]}\n" if f[:description] && !f[:description].empty?
              if f[:suggestion] && !f[:suggestion].empty?
                content += "  - **Suggestion:** #{f[:suggestion]}\n"
              end
              content += "\n"
            end
          end

          content
        end
      end
    end
  end
end

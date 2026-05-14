module Reviewbot
  module Formatters
    module Markdown
      class FileBreakdownSection
        def generate(findings)
          return nil if findings.nil? || findings.empty?

          grouped = findings.group_by { |f| f[:file] }
          return nil if grouped.empty?

          content = "## Files Changed\n\n"

          grouped.each do |file, file_findings|
            content += "### #{file}\n\n"
            file_findings.each do |f|
              line_info = f[:line] ? " (line #{f[:line]})" : ""
              severity_icon = case f[:severity]
                              when "critical" then "🔴"
                              when "high" then "⚠️"
                              when "medium" then "🔶"
                              else "ℹ️"
                              end
              content += "- #{severity_icon} [#{f[:severity].upcase}] #{f[:title]}#{line_info}\n"
            end
            content += "\n"
          end

          content
        end
      end
    end
  end
end

module Reviewbot
  module Formatters
    module Markdown
      class MissingTestsSection
        def generate(missing_tests)
          return nil if missing_tests.nil? || missing_tests.empty?

          content = "## Missing Tests\n\n"
          content += "The following source files may be missing corresponding test coverage:\n\n"

          missing_tests.each do |entry|
            file = entry[:file] || entry["file"]
            reason = entry[:reason] || entry["reason"] || "No test file found"
            content += "- **#{file}**: #{reason}\n"
          end

          content += "\n"
          content
        end
      end
    end
  end
end

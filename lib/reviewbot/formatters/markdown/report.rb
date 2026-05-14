module Reviewbot
  module Formatters
    module Markdown
      class Report
        def initialize
          @pastel = Pastel.new
        end

        def generate(pr_data:, review_result:)
          sections = []

          sections << SummarySection.new.generate(pr_data, review_result)
          sections << FindingsSection.new.generate(review_result[:findings])
          sections << FileBreakdownSection.new.generate(review_result[:findings])
          sections << MissingTestsSection.new.generate(review_result[:missing_tests])
          sections << ArchitectureNotesSection.new.generate(review_result[:architecture_notes])
          sections << SecurityNotesSection.new.generate(review_result[:security_notes])

          sections.compact.join("\n\n---\n\n")
        end

        def generate_to_file(pr_data:, review_result:, output_dir: "reviews")
          FileUtils.mkdir_p(output_dir)
          content = generate(pr_data: pr_data, review_result: review_result)
          file_path = File.join(output_dir, "pr-#{pr_data[:number]}-review.md")
          File.write(file_path, content)
          file_path
        end
      end
    end
  end
end

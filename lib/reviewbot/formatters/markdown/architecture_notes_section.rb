module Reviewbot
  module Formatters
    module Markdown
      class ArchitectureNotesSection
        def generate(notes)
          return nil if notes.nil? || notes.empty?

          content = "## Architecture Notes\n\n"
          notes.each do |note|
            content += "- #{note.is_a?(Hash) ? note[:text] || note["text"] : note}\n"
          end
          content += "\n"
          content
        end
      end
    end
  end
end

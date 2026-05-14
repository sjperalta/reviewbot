module Reviewbot
  module Formatters
    module Markdown
      class SecurityNotesSection
        def generate(notes)
          return nil if notes.nil? || notes.empty?

          content = "## Security Notes\n\n"
          notes.each do |note|
            text = note.is_a?(Hash) ? (note[:description] || note["description"] || note[:title] || note["title"] || note.to_s) : note.to_s
            content += "- ⚠️ #{text}\n"
          end
          content += "\n"
          content
        end
      end
    end
  end
end

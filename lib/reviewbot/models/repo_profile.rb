module Reviewbot
  module Models
    class RepoProfile
      attr_reader :primary_stack, :stacks, :languages, :frameworks, :has_typescript, :has_react, :detected_files

      def initialize(primary_stack: "unknown", stacks: [], languages: [], frameworks: [], has_typescript: false, has_react: false, detected_files: {})
        @primary_stack = primary_stack
        @stacks = stacks
        @languages = languages
        @frameworks = frameworks
        @has_typescript = has_typescript
        @has_react = has_react
        @detected_files = detected_files
      end

      def rails?
        @stacks.include?("rails")
      end

      def ruby?
        @stacks.include?("ruby") || rails?
      end

      def javascript?
        @stacks.include?("javascript")
      end

      def typescript?
        @has_typescript || @stacks.include?("typescript")
      end

      def react?
        @has_react
      end

      def flutter?
        @stacks.include?("flutter")
      end

      def dart?
        @stacks.include?("dart")
      end

      def go?
        @stacks.include?("go")
      end

      def node?
        javascript? || typescript?
      end

      def to_hash
        {
          primary_stack: @primary_stack,
          stacks: @stacks,
          languages: @languages,
          frameworks: @frameworks,
          has_typescript: @has_typescript,
          has_react: @has_react,
          detected_files: @detected_files
        }
      end
    end
  end
end

module Reviewbot
  module Services
    class RepoDetector
      def initialize
        @detectors = [
          Services::Detectors::RailsDetector.new,
          Services::Detectors::RubyDetector.new,
          Services::Detectors::NodeDetector.new,
          Services::Detectors::FlutterDetector.new,
          Services::Detectors::DartDetector.new,
          Services::Detectors::GoDetector.new
        ]
      end

      def detect(repo_path)
        results = @detectors.map { |d| d.detect(repo_path) }.compact
        merge_results(results)
      end

      def detect_from_files(detected_files)
        results = @detectors.map { |d| d.detect_from_file_list(detected_files) }.compact
        merge_results(results)
      end

      private

      def merge_results(results)
        stacks = results.flat_map { |r| r[:stacks] || [] }.uniq
        languages = results.flat_map { |r| r[:languages] || [] }.uniq
        frameworks = results.flat_map { |r| r[:frameworks] || [] }.uniq
        detected_files = results.each_with_object({}) { |r, h| h.merge!(r[:detected_files] || {}) }
        has_typescript = results.any? { |r| r[:has_typescript] }
        has_react = results.any? { |r| r[:has_react] }

        primary_stack = determine_primary(stacks, results)

        Models::RepoProfile.new(
          primary_stack: primary_stack,
          stacks: stacks,
          languages: languages,
          frameworks: frameworks,
          has_typescript: has_typescript,
          has_react: has_react,
          detected_files: detected_files
        )
      end

      def determine_primary(stacks, results)
        priority = %w[rails flutter react typescript ruby go dart javascript]
        priority.each do |stack|
          return stack if stacks.include?(stack)
        end
        stacks.first || "unknown"
      end
    end
  end
end

module Reviewbot
  module Services
    module Detectors
      class RubyDetector
        def detect(repo_path)
          gemfile = File.join(repo_path, "Gemfile")
          return nil unless File.exist?(gemfile)

          {
            stacks: ["ruby"],
            languages: ["ruby"],
            frameworks: [],
            has_typescript: false,
            has_react: false,
            detected_files: { gemfile: gemfile }
          }
        end

        def detect_from_file_list(files)
          return nil unless files.include?("Gemfile")

          {
            stacks: ["ruby"],
            languages: ["ruby"],
            frameworks: [],
            has_typescript: false,
            has_react: false,
            detected_files: { gemfile: "Gemfile" }
          }
        end
      end
    end
  end
end

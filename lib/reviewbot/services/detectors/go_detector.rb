module Reviewbot
  module Services
    module Detectors
      class GoDetector
        def detect(repo_path)
          go_mod = File.join(repo_path, "go.mod")
          return nil unless File.exist?(go_mod)

          {
            stacks: ["go"],
            languages: ["go"],
            frameworks: [],
            has_typescript: false,
            has_react: false,
            detected_files: { go_mod: go_mod }
          }
        end

        def detect_from_file_list(files)
          return nil unless files.include?("go.mod")

          {
            stacks: ["go"],
            languages: ["go"],
            frameworks: [],
            has_typescript: false,
            has_react: false,
            detected_files: { go_mod: "go.mod" }
          }
        end
      end
    end
  end
end

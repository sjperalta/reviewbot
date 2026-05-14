module Reviewbot
  module Services
    module Detectors
      class DartDetector
        def detect(repo_path)
          pubspec = File.join(repo_path, "pubspec.yaml")
          return nil unless File.exist?(pubspec)

          content = File.read(pubspec)
          has_flutter_sdk = content.include?("flutter:")
          return nil if has_flutter_sdk

          has_dart_files = !Dir.glob(File.join(repo_path, "**/*.dart")).empty?
          return nil unless has_dart_files

          {
            stacks: ["dart"],
            languages: ["dart"],
            frameworks: [],
            has_typescript: false,
            has_react: false,
            detected_files: { pubspec: pubspec }
          }
        end

        def detect_from_file_list(files)
          return nil unless files.include?("pubspec.yaml")
          has_dart = files.any? { |f| f.end_with?(".dart") }
          return nil unless has_dart

          {
            stacks: ["dart"],
            languages: ["dart"],
            frameworks: [],
            has_typescript: false,
            has_react: false,
            detected_files: { pubspec: "pubspec.yaml" }
          }
        end
      end
    end
  end
end

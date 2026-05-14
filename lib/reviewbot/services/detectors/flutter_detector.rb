module Reviewbot
  module Services
    module Detectors
      class FlutterDetector
        def detect(repo_path)
          pubspec = File.join(repo_path, "pubspec.yaml")
          return nil unless File.exist?(pubspec)

          content = File.read(pubspec)
          has_flutter_sdk = content.include?("flutter:")
          return nil unless has_flutter_sdk

          {
            stacks: ["flutter", "dart"],
            languages: ["dart"],
            frameworks: ["flutter"],
            has_typescript: false,
            has_react: false,
            detected_files: { pubspec: pubspec }
          }
        end

        def detect_from_file_list(files)
          return nil unless files.include?("pubspec.yaml")

          {
            stacks: ["flutter", "dart"],
            languages: ["dart"],
            frameworks: ["flutter"],
            has_typescript: false,
            has_react: false,
            detected_files: { pubspec: "pubspec.yaml" }
          }
        end
      end
    end
  end
end

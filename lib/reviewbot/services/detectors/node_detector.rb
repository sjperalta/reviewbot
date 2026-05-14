module Reviewbot
  module Services
    module Detectors
      class NodeDetector
        def detect(repo_path)
          package_json = File.join(repo_path, "package.json")
          tsconfig = File.join(repo_path, "tsconfig.json")

          return nil unless File.exist?(package_json)

          content = JSON.parse(File.read(package_json))
          deps = (content["dependencies"] || {}).merge(content["devDependencies"] || {})

          stacks = []
          languages = []
          frameworks = []
          has_react = false
          has_typescript = File.exist?(tsconfig)

          stacks << "javascript"
          languages << "javascript"

          if has_typescript
            stacks << "typescript"
            languages << "typescript"
          end

          if deps.key?("react") || deps.key?("react-dom")
            has_react = true
            stacks << "react"
            frameworks << "react"
          end

          {
            stacks: stacks,
            languages: languages,
            frameworks: frameworks,
            has_typescript: has_typescript,
            has_react: has_react,
            detected_files: { package_json: package_json }
          }
        rescue JSON::ParserError
          nil
        end

        def detect_from_file_list(files)
          return nil unless files.include?("package.json")

          has_ts = files.include?("tsconfig.json") || files.any? { |f| f.end_with?(".ts") || f.end_with?(".tsx") }
          stacks = ["javascript"]
          languages = ["javascript"]
          frameworks = []

          if has_ts
            stacks << "typescript"
            languages << "typescript"
          end

          { stacks: stacks, languages: languages, frameworks: frameworks, has_typescript: has_ts, has_react: false, detected_files: { package_json: "package.json" } }
        end
      end
    end
  end
end

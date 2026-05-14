module Reviewbot
  module Services
    module Detectors
      class RailsDetector
        def detect(repo_path)
          gemfile = File.join(repo_path, "Gemfile")
          app_dir = File.join(repo_path, "app")
          config_app = File.join(repo_path, "config", "application.rb")

          return nil unless File.exist?(gemfile)

          has_rails = false
          if File.exist?(gemfile)
            content = File.read(gemfile)
            has_rails = content.include?("gem 'rails'") || content.include?('gem "rails"')
          end

          return nil unless has_rails && (Dir.exist?(app_dir) || File.exist?(config_app))

          {
            stacks: ["rails", "ruby"],
            languages: ["ruby"],
            frameworks: ["rails"],
            has_typescript: false,
            has_react: false,
            detected_files: { gemfile: gemfile, config_app: config_app }
          }
        end

        def detect_from_file_list(files)
          return nil unless files.include?("Gemfile") || files.include?("config/application.rb")

          {
            stacks: ["rails", "ruby"],
            languages: ["ruby"],
            frameworks: ["rails"],
            has_typescript: false,
            has_react: false,
            detected_files: { gemfile: "Gemfile" }
          }
        end
      end
    end
  end
end

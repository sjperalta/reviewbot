module Reviewbot
  module Services
    class FileCategorizer
      TEST_PATTERNS = [
        /\btest\b/i, /\bspec\b/i, /_test\./, /_spec\./, /\.test\./, /\.spec\./,
        /__tests__/, /__mocks__/, "/test/", "/spec/"
      ].freeze

      CONFIG_PATTERNS = [
        /\.json$/, /\.ya?ml$/, /\.toml$/, /\.ini$/, /\.cfg$/,
        /Dockerfile/, /\.dockerfile$/, /\.github\//, /\.gitlab/,
        "Gemfile", "Gemfile.lock", "Rakefile", "Guardfile"
      ].freeze

      GENERATED_PATTERNS = [
        /\.min\./, /\.generated\./, /_pb\.rb$/, /_pb\.go$/,
        /\.pb\.go$/, /_grpc\./, /thrift/
      ].freeze

      BINARY_EXTENSIONS = %w[.png .jpg .jpeg .gif .svg .ico .woff .woff2 .eot .ttf .otf .pdf .zip .gz .tar .exe .dll .so .dylib .o .class .pyc].freeze

      LOCKFILES = %w[Gemfile.lock yarn.lock package-lock.json yarn.lock pnpm-lock.yaml composer.lock Cargo.lock go.sum poetry.lock].freeze

      VENDOR_PATTERNS = [/^vendor\//, /^node_modules\//, /^bower_components\//, /^\.bundle\//, /^third_party\//].freeze

      SNAPSHOT_PATTERNS = [/__snapshots__/, /\.snap$/].freeze

      def categorize(files)
        files.each do |file|
          file.category = determine_category(file.path)
        end
        files
      end

      def determine_category(path)
        return "binary" if BINARY_EXTENSIONS.include?(File.extname(path).downcase)
        return "lockfile" if LOCKFILES.include?(File.basename(path))
        return "vendor" if VENDOR_PATTERNS.any? { |p| path.match?(p) }
        return "snapshot" if SNAPSHOT_PATTERNS.any? { |p| path.match?(p) }
        return "generated" if GENERATED_PATTERNS.any? { |p| path.match?(p) }
        return "config" if CONFIG_PATTERNS.any? { |p| file_matches?(path, p) }
        return "test" if TEST_PATTERNS.any? { |p| path.match?(p) }
        "source"
      end

      private

      def file_matches?(path, pattern)
        if pattern.is_a?(Regexp)
          path.match?(pattern)
        else
          path.include?(pattern) || File.basename(path) == pattern
        end
      end
    end
  end
end

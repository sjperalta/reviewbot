module Reviewbot
  module CLI
    class Review
      def initialize(display: nil, spinner: nil)
        @display = display || Reviewbot::Formatters::Terminal::Display.new
        @spinner = spinner || TTY::Spinner.new("[:spinner] :title", format: :dots)
      end

      def run(pr_number: nil, options: {})
        config_loader = Reviewbot::Config::Loader.new.load!
        validator = Reviewbot::Config::Validator.new(loader: config_loader)
        errors = validator.validate_soft
        errors.each { |e| @display.warning(e) }

        opts = Reviewbot::Config::Options.new(cli_options: options, loader: config_loader)

        coordinator = build_coordinator

        if options[:all]
          review_all(coordinator, opts)
        else
          review_single(coordinator, pr_number, opts)
        end
      end

      private

      def build_coordinator
        cache = Reviewbot::Cache::Manager.new
        ai_cache = Reviewbot::AI::ReviewCache.new(db: cache.database)
        ai_cache.migrate!
        ai_engine = Reviewbot::AI::ReviewEngine.new(cache: ai_cache)

        Reviewbot::Services::ReviewCoordinator.new(
          cache: cache,
          ai_engine: ai_engine
        )
      end

      def review_single(coordinator, pr_number, opts)
        manager = Reviewbot::Services::PRManager.new

        pr_data = with_spinner("Preparing PR") do
          manager.select_and_prepare(pr_number: pr_number)
        end

        unless pr_data
          if pr_number
            @display.error(
              "PR ##{pr_number} is not in your assigned open PRs (see `reviewbot prs` or GitHub review requests)."
            )
          else
            @display.warning("No PR selected.")
          end
          return
        end

        @display.info("Reviewing PR ##{pr_data[:number]}: #{pr_data[:title]}")

        result = with_spinner("Running review") do
          coordinator.review_pr(pr_data: pr_data, options: opts)
        end

        if result
          Reviewbot::Formatters::Terminal::FindingsSummary.new.render(result)

          with_spinner("Exporting report") do
            exporter = Reviewbot::Services::ReportExporter.new
            path = exporter.export(pr_data: pr_data, review_result: result, output_dir: opts.output_dir)
            @display.success("Report exported to #{path}")
          end
        end

        manager.cleanup
      end

      def review_all(coordinator, opts)
        manager = Reviewbot::Services::PRManager.new

        prs_data = with_spinner("Fetching all PRs") do
          manager.prepare_all
        end

        if prs_data.empty?
          @display.warning("No PRs to review.")
          return
        end

        prs_data.each do |pr_data|
          @display.info("Reviewing PR ##{pr_data[:number]}: #{pr_data[:title]}")

          result = coordinator.review_pr(pr_data: pr_data, options: opts)

          if result
            exporter = Reviewbot::Services::ReportExporter.new
            path = exporter.export(pr_data: pr_data, review_result: result, output_dir: opts.output_dir)
            @display.success("Report exported to #{path}")
          end
        end

        manager.cleanup
      end

      def with_spinner(title)
        @spinner.update(title: title)
        @spinner.auto_spin
        result = yield
        @spinner.success
        result
      rescue => e
        @spinner.error("(#{e.message})")
        Reviewbot::Utils::Logger.error("Review failed: #{e.message}")
        nil
      end
    end
  end
end

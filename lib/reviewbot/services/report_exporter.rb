module Reviewbot
  module Services
    class ReportExporter
      def initialize(report: nil)
        @report = report || Reviewbot::Formatters::Markdown::Report.new
      end

      def export(pr_data:, review_result:, output_dir: "reviews")
        path = @report.generate_to_file(
          pr_data: pr_data,
          review_result: review_result,
          output_dir: output_dir
        )
        Reviewbot::Utils::Logger.info "Report exported to #{path}"
        path
      end
    end
  end
end

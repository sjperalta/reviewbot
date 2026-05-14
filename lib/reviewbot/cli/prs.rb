module Reviewbot
  module CLI
    class PRS
      def initialize(pr_lister: nil, pr_table: nil, display: nil)
        @pr_lister = pr_lister || Reviewbot::GitHub::PRLister.new
        @pr_table = pr_table || Reviewbot::Formatters::Terminal::PRTable.new
        @display = display || Reviewbot::Formatters::Terminal::Display.new
      end

      def run
        @display.header("Assigned Pull Requests")
        prs = @pr_lister.list_assigned
        @pr_table.render(prs)
        prs
      end
    end
  end
end
